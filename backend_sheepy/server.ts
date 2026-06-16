import express, { type Request, type Response, type NextFunction } from 'express';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import cors from 'cors';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_sheepy_2026';

// Middleware
app.use(cors());
app.use(express.json());

// Middleware personalizado para logs de peticiones
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.originalUrl} - Status: ${res.statusCode} (${duration}ms)`);
  });

  next();
});

// Configuración de la conexión a MySQL
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'tu_password_aqui',
  database: process.env.DB_NAME || 'biblia_rv1909',
  port: Number(process.env.DB_PORT) || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function initDB() {
  try {
    // Asegurar tabla user_progress
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_progress (
        id INT NOT NULL AUTO_INCREMENT,
        user_id INT NOT NULL,
        book_number INT NOT NULL,
        chapter INT NOT NULL,
        completed_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY idx_user_chapter (user_id, book_number, chapter),
        CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    `);

    // Asegurar tabla user_streaks
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_streaks (
        user_id INT NOT NULL,
        current_streak INT NOT NULL DEFAULT 0,
        longest_streak INT NOT NULL DEFAULT 0,
        last_activity DATE NULL,
        PRIMARY KEY (user_id),
        CONSTRAINT fk_streaks_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    `);

    // Añadir columnas a users si no existen
    const [columns]: any = await pool.query("SHOW COLUMNS FROM users");
    const colNames = columns.map((c: any) => c.Field);
    
    if (!colNames.includes('coins')) {
      await pool.query("ALTER TABLE users ADD COLUMN coins INT NOT NULL DEFAULT 0");
    }
    if (!colNames.includes('lives')) {
      await pool.query("ALTER TABLE users ADD COLUMN lives INT NOT NULL DEFAULT 5");
    }
    if (!colNames.includes('last_life_refill')) {
      await pool.query("ALTER TABLE users ADD COLUMN last_life_refill TIMESTAMP NULL");
    }
    console.log("Base de datos sincronizada con éxito.");
  } catch (error) {
    console.error("Error al sincronizar base de datos:", error);
  }
}
initDB();

// Tipados
interface Verse {
  verse_id: number;
  book_name: string;
  book_number: number;
  chapter: number;
  verse: number;
  text: string;
}

// Middleware de autenticación
const authenticateToken = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) {
    res.sendStatus(401);
    return;
  }

  jwt.verify(token, JWT_SECRET, (err: any, user: any) => {
    if (err) {
      res.sendStatus(403);
      return;
    }
    (req as any).user = user;
    next();
  });
};

// ---------------------------------------------------------
// RUTAS DE AUTENTICACIÓN Y USUARIOS
// ---------------------------------------------------------

app.post('/api/auth/register', async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, email, password } = req.body;
    
    if (!username || !email || !password) {
      res.status(400).json({ error: 'Faltan campos requeridos' });
      return;
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const [result] = await pool.query(
      'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
      [username, email, hashedPassword]
    );

    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (error: any) {
    console.error(error);
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ error: 'El usuario o email ya existe' });
    } else {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  }
});

app.post('/api/auth/login', async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ error: 'Faltan campos requeridos' });
      return;
    }

    const [rows]: any = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    const user = rows[0];

    if (!user) {
      res.status(401).json({ error: 'Credenciales inválidas' });
      return;
    }

    const match = await bcrypt.compare(password, user.password_hash);
    
    if (!match) {
      res.status(401).json({ error: 'Credenciales inválidas' });
      return;
    }

    const token = jwt.sign(
      { userId: user.id, username: user.username, role: 'user' },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      message: 'Login exitoso',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        points: user.points,
        league_id: user.league_id
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint perfil: devuelve el perfil de usuario calculando las vidas perezosamente
app.get('/api/users/me', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const [rows]: any = await pool.query(`
      SELECT 
        u.id, u.username, u.email, u.points, u.league_id, l.name as league_name, l.color_hex,
        u.coins,
        LEAST(5, u.lives + FLOOR(TIMESTAMPDIFF(MINUTE, u.last_life_refill, NOW()) / 15)) as current_lives,
        CASE 
          WHEN LEAST(5, u.lives + FLOOR(TIMESTAMPDIFF(MINUTE, u.last_life_refill, NOW()) / 15)) >= 5 THEN 0 
          ELSE 15 - (TIMESTAMPDIFF(MINUTE, u.last_life_refill, NOW()) % 15) 
        END as minutes_until_next_life,
        COALESCE(us.current_streak, 0) as current_streak,
        COALESCE(us.longest_streak, 0) as longest_streak
      FROM users u
      LEFT JOIN leagues l ON u.league_id = l.id
      LEFT JOIN user_streaks us ON u.id = us.user_id
      WHERE u.id = ?
    `, [userId]);

    if (rows.length === 0) {
      res.status(404).json({ error: 'Usuario no encontrado' });
      return;
    }

    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint para restar una vida
app.post('/api/users/lose_life', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    
    // Primero, calcular las vidas actuales y sincronizar la base de datos
    await pool.query(`
      UPDATE users 
      SET 
        last_life_refill = CASE 
          WHEN LEAST(5, lives + FLOOR(TIMESTAMPDIFF(MINUTE, last_life_refill, NOW()) / 15)) >= 5 THEN NOW()
          ELSE DATE_ADD(NOW(), INTERVAL -(TIMESTAMPDIFF(MINUTE, last_life_refill, NOW()) % 15) MINUTE)
        END,
        lives = LEAST(5, lives + FLOOR(TIMESTAMPDIFF(MINUTE, last_life_refill, NOW()) / 15)) - 1
      WHERE id = ? AND LEAST(5, lives + FLOOR(TIMESTAMPDIFF(MINUTE, last_life_refill, NOW()) / 15)) > 0
    `, [userId]);

    res.json({ success: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint para guardar progreso tras finalizar cuestionario con éxito
app.post('/api/users/progress', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { book_number, chapter } = req.body;
    
    if (!book_number || !chapter) {
      res.status(400).json({ error: 'Faltan campos (book_number, chapter)' });
      return;
    }

    // Insertar progreso (ignora si ya existe gracias al UNIQUE constraint)
    const [progressResult]: any = await pool.query(
      'INSERT IGNORE INTO user_progress (user_id, book_number, chapter) VALUES (?, ?, ?)',
      [userId, book_number, chapter]
    );

    // Si fue un nuevo capítulo completado, otorgar puntos y actualizar racha
    if (progressResult.affectedRows > 0) {
      await pool.query(
        'UPDATE users SET points = points + 10, coins = coins + 5 WHERE id = ?',
        [userId]
      );
      
      // Actualizar la racha
      await pool.query(`
        INSERT INTO user_streaks (user_id, current_streak, longest_streak, last_activity)
        VALUES (?, 1, 1, CURDATE())
        ON DUPLICATE KEY UPDATE
          current_streak = CASE 
            WHEN last_activity = CURDATE() THEN current_streak
            WHEN last_activity = CURDATE() - INTERVAL 1 DAY THEN current_streak + 1
            ELSE 1
          END,
          longest_streak = GREATEST(longest_streak, CASE 
            WHEN last_activity = CURDATE() THEN current_streak
            WHEN last_activity = CURDATE() - INTERVAL 1 DAY THEN current_streak + 1
            ELSE 1
          END),
          last_activity = CURDATE()
      `, [userId]);
    }

    res.json({ success: true, new_chapter: progressResult.affectedRows > 0 });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno' });
  }
});

// ---------------------------------------------------------
// RUTAS DE LA BIBLIA, LIBROS Y LIGAS
// ---------------------------------------------------------

// Endpoint de catálogo de libros con progreso del usuario
app.get('/api/books', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const [rows] = await pool.query(`
      SELECT b.book_number, b.name, b.total_chapters,
             COUNT(up.chapter) as completed_chapters
      FROM books b
      LEFT JOIN user_progress up ON b.book_number = up.book_number AND up.user_id = ?
      GROUP BY b.book_number, b.name, b.total_chapters
      ORDER BY b.book_number ASC
    `, [userId]);

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno' });
  }
});

// Endpoint de Leaderboard (Clasificación de Liga)
app.get('/api/leagues/leaderboard', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    
    // Obtener la liga del usuario
    const [userRows]: any = await pool.query('SELECT league_id FROM users WHERE id = ?', [userId]);
    if (userRows.length === 0) {
      res.status(404).json({ error: 'Usuario no encontrado' });
      return;
    }
    const leagueId = userRows[0].league_id;

    // Obtener el ranking
    const [rows] = await pool.query(`
      SELECT u.id, u.username, u.points, l.name as league_name, l.color_hex
      FROM users u
      JOIN leagues l ON u.league_id = l.id
      WHERE u.league_id = ?
      ORDER BY u.points DESC
    `, [leagueId]);

    // Obtener puntos necesarios para la siguiente liga
    const [nextLeagueRows]: any = await pool.query(`
      SELECT min_points FROM leagues WHERE min_points > (SELECT min_points FROM leagues WHERE id = ?) ORDER BY min_points ASC LIMIT 1
    `, [leagueId]);
    
    const nextLeaguePoints = nextLeagueRows.length > 0 ? nextLeagueRows[0].min_points : null;

    res.json({
      leaderboard: rows,
      next_league_points: nextLeaguePoints
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno' });
  }
});

// Endpoint de Versículos de un Capítulo
app.get('/api/book/:bookNumber/chapter/:chapter', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  const { bookNumber, chapter } = req.params;

  try {
    const [rows] = await pool.query(
      'SELECT v.verse_id, b.name as book_name, v.book_number, v.chapter, v.verse, v.text FROM verses v JOIN books b ON v.book_number = b.book_number WHERE v.book_number = ? AND v.chapter = ? ORDER BY v.verse ASC',
      [bookNumber, chapter]
    );

    const verses = rows as Verse[];

    if (verses.length === 0) {
      res.status(404).json({ error: 'Capítulo o libro no encontrado' });
      return;
    }

    const firstVerse = verses[0]!;

    res.json({
      book_name: firstVerse.book_name,
      book_number: firstVerse.book_number,
      chapter: firstVerse.chapter,
      verses: verses.map(v => ({
        verse: v.verse,
        text: v.text
      }))
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint de Capítulos completados por el usuario
app.get('/api/users/completed_chapters', authenticateToken, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const [rows]: any = await pool.query(`
      SELECT book_number, chapter 
      FROM user_progress 
      WHERE user_id = ?
    `, [userId]);

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno' });
  }
});

// ---------------------------------------------------------
// STARTUP
// ---------------------------------------------------------

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
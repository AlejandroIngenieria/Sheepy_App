import express, { Request, Response, NextFunction } from 'express';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware personalizado para logs de peticiones
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  // Al terminar de enviar la respuesta, se imprime el log
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

// Interface para el tipado del versículo
interface Verse {
  verse_id: number;
  book_name: string;
  book_number: number;
  chapter: number;
  verse: number;
  text: string;
}

// Endpoint para obtener los versículos de un capítulo específico de un libro
app.get('/api/book/:bookNumber/chapter/:chapter', async (req: Request, res: Response): Promise<void> => {
  const { bookNumber, chapter } = req.params;

  try {
    const [rows] = await pool.query(
      'SELECT verse_id, book_name, book_number, chapter, verse, text FROM verses WHERE book_number = ? AND chapter = ? ORDER BY verse ASC',
      [bookNumber, chapter]
    );

    const verses = rows as Verse[];

    if (verses.length === 0) {
      res.status(404).json({ error: 'Capítulo o libro no encontrado' });
      return;
    }

    res.json({
      book_name: verses[0].book_name,
      book_number: verses[0].book_number,
      chapter: verses[0].chapter,
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

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
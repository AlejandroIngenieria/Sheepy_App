CREATE DATABASE IF NOT EXISTS biblia_rv1909;
USE biblia_rv1909;

-- biblia_rv1909.achievements definition

CREATE TABLE `achievements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `reward_coins` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.books definition

CREATE TABLE `books` (
  `book_number` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `total_chapters` int DEFAULT '0',
  PRIMARY KEY (`book_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.leagues definition

CREATE TABLE `leagues` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `min_points` int NOT NULL DEFAULT '0',
  `color_hex` varchar(7) NOT NULL DEFAULT '#FFFFFF',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.quizzes definition

CREATE TABLE `quizzes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_number` int NOT NULL,
  `chapter` int NOT NULL,
  `question` text NOT NULL,
  `option_a` varchar(255) NOT NULL,
  `option_b` varchar(255) NOT NULL,
  `option_c` varchar(255) NOT NULL,
  `option_d` varchar(255) NOT NULL,
  `correct_option` char(1) NOT NULL COMMENT 'A, B, C, or D',
  PRIMARY KEY (`id`),
  KEY `idx_quiz_chapter` (`book_number`,`chapter`),
  CONSTRAINT `fk_quizzes_books` FOREIGN KEY (`book_number`) REFERENCES `books` (`book_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.users definition

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `points` int NOT NULL DEFAULT '0',
  `league_id` int NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lives` int NOT NULL DEFAULT '5',
  `coins` int NOT NULL DEFAULT '0',
  `last_life_refill` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `league_id` (`league_id`),
  KEY `idx_ranking` (`points` DESC),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`league_id`) REFERENCES `leagues` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.verses definition

CREATE TABLE `verses` (
  `verse_id` int NOT NULL AUTO_INCREMENT,
  `book_number` int NOT NULL,
  `chapter` int NOT NULL,
  `verse` int NOT NULL,
  `text` text NOT NULL,
  PRIMARY KEY (`verse_id`),
  KEY `idx_book_chapter` (`book_number`,`chapter`),
  CONSTRAINT `fk_verses_books` FOREIGN KEY (`book_number`) REFERENCES `books` (`book_number`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=31103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.notifications definition

CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_read` (`user_id`,`is_read`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.quiz_attempts definition

CREATE TABLE `quiz_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `quiz_id` int NOT NULL,
  `is_correct` tinyint(1) NOT NULL,
  `attempted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_quiz` (`user_id`,`quiz_id`),
  KEY `fk_attempt_quiz` (`quiz_id`),
  CONSTRAINT `fk_attempt_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_attempt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.user_achievements definition

CREATE TABLE `user_achievements` (
  `user_id` int NOT NULL,
  `achievement_id` int NOT NULL,
  `unlocked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`achievement_id`),
  KEY `fk_ua_achieve` (`achievement_id`),
  CONSTRAINT `fk_ua_achieve` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ua_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.user_followers definition

CREATE TABLE `user_followers` (
  `follower_id` int NOT NULL,
  `followed_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follower_id`,`followed_id`),
  KEY `fk_followed` (`followed_id`),
  CONSTRAINT `fk_followed` FOREIGN KEY (`followed_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.user_progress definition

CREATE TABLE `user_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_number` int NOT NULL,
  `chapter` int NOT NULL,
  `completed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_chapter` (`user_id`,`book_number`,`chapter`),
  CONSTRAINT `fk_progress_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- biblia_rv1909.user_streaks definition

CREATE TABLE `user_streaks` (
  `user_id` int NOT NULL,
  `current_streak` int DEFAULT '0',
  `longest_streak` int DEFAULT '0',
  `last_activity` date DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_streaks_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- TRIGGER

CREATE EVENT event_refill_lives
ON SCHEDULE EVERY 30 MINUTE
DO
BEGIN
    UPDATE users 
    SET 
        lives = lives + 1,
        last_life_refill = CURRENT_TIMESTAMP
    WHERE lives < 5;
END;
-- ============================================================
-- phpMyAdmin SQL Dump
-- Sistem Produksi Jamu - Penjamu Handal
--
-- Host: localhost:3306
-- Database: jamu
--
-- CARA IMPORT DI phpMyAdmin:
--   1. Buka phpMyAdmin
--   2. Klik tab "Import"
--   3. Pilih file ini (jamu.sql)
--   4. Klik "Go"
--
-- ATAU via terminal:
--   mysql -u root -p < jamu.sql
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- Buat database jamu (jika belum ada)
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `jamu`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `jamu`;

-- ------------------------------------------------------------
-- Tabel: kota
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `kota` (
  `id_kota`   INT AUTO_INCREMENT PRIMARY KEY,
  `nama_kota` VARCHAR(100) NOT NULL,
  `ket_kota`  TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: user (admin/staff)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `id_user`    INT AUTO_INCREMENT PRIMARY KEY,
  `id_kota`    INT,
  `username`   VARCHAR(100) NOT NULL UNIQUE,
  `email`      VARCHAR(150) NOT NULL UNIQUE,
  `pw`         VARCHAR(255) NOT NULL,
  `role`       ENUM('admin','supervisor','staff') NOT NULL DEFAULT 'staff',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_kota`) REFERENCES `kota`(`id_kota`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: produsen (supplier/pemasok)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `produsen` (
  `id_produsen`   INT AUTO_INCREMENT PRIMARY KEY,
  `nama_produsen` VARCHAR(200) NOT NULL,
  `alamat`        TEXT,
  `kota`          VARCHAR(100),
  `kontak`        VARCHAR(100),
  `email`         VARCHAR(150),
  `status`        ENUM('aktif','menunggu','ditangguhkan') DEFAULT 'aktif',
  `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: jamu (resep/produk jamu)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `jamu` (
  `id_jamu`     INT AUTO_INCREMENT PRIMARY KEY,
  `id_user`     INT,
  `nama_jamu`   VARCHAR(200) NOT NULL,
  `ket_jamu`    TEXT,
  `jenis`       VARCHAR(50),
  `perizinan`   VARCHAR(50),
  `id_produsen` INT,
  `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_user`)     REFERENCES `user`(`id_user`)         ON DELETE SET NULL,
  FOREIGN KEY (`id_produsen`) REFERENCES `produsen`(`id_produsen`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: rempah (master bahan baku)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `rempah` (
  `id_rempah`   INT AUTO_INCREMENT PRIMARY KEY,
  `nama_rempah` VARCHAR(200) NOT NULL,
  `ket_rempah`  TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: bahan (inventaris stok bahan baku)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bahan` (
  `id`          INT AUTO_INCREMENT PRIMARY KEY,
  `nama`        VARCHAR(200) NOT NULL,
  `kategori`    VARCHAR(100),
  `satuan`      VARCHAR(20),
  `stokAwal`    DECIMAL(10,2) DEFAULT 0,
  `hargaSatuan` DECIMAL(15,2) DEFAULT 0,
  `threshold`   DECIMAL(10,2) DEFAULT 10,
  `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: khasiat
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `khasiat` (
  `id_khasiat`  INT AUTO_INCREMENT PRIMARY KEY,
  `khasiat`     VARCHAR(200) NOT NULL,
  `ket_khasiat` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: komposisi (relasi jamu <-> rempah)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `komposisi` (
  `id_komposisi`  INT AUTO_INCREMENT PRIMARY KEY,
  `id_rempah`     INT NOT NULL,
  `id_jamu`       INT NOT NULL,
  `banyak_rempah` VARCHAR(100),
  FOREIGN KEY (`id_rempah`) REFERENCES `rempah`(`id_rempah`) ON DELETE CASCADE,
  FOREIGN KEY (`id_jamu`)   REFERENCES `jamu`(`id_jamu`)     ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: khasiat_jamu (relasi jamu <-> khasiat)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `khasiat_jamu` (
  `id_khasiat_jamu` INT AUTO_INCREMENT PRIMARY KEY,
  `id_khasiat`      INT NOT NULL,
  `id_jamu`         INT NOT NULL,
  FOREIGN KEY (`id_khasiat`) REFERENCES `khasiat`(`id_khasiat`) ON DELETE CASCADE,
  FOREIGN KEY (`id_jamu`)    REFERENCES `jamu`(`id_jamu`)       ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabel: produksi (batch produksi)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `produksi` (
  `id_produksi`   INT AUTO_INCREMENT PRIMARY KEY,
  `id_jamu`       INT NOT NULL,
  `id_user`       INT,
  `kode_batch`    VARCHAR(50) UNIQUE,
  `ukuran_batch`  DECIMAL(10,2),
  `volume_output` DECIMAL(10,2),
  `efisiensi`     DECIMAL(5,2),
  `status`        ENUM('antrian','ekstraksi','botolisasi','selesai') DEFAULT 'antrian',
  `catatan`       TEXT,
  `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_jamu`) REFERENCES `jamu`(`id_jamu`) ON DELETE RESTRICT,
  FOREIGN KEY (`id_user`) REFERENCES `user`(`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Data awal: Kota Madura
-- ------------------------------------------------------------
INSERT IGNORE INTO `kota` (`id_kota`, `nama_kota`, `ket_kota`) VALUES
  (1, 'Sampang',   'Kabupaten Sampang, Madura'),
  (2, 'Sumenep',   'Kabupaten Sumenep, Madura'),
  (3, 'Pamekasan', 'Kabupaten Pamekasan, Madura'),
  (4, 'Bangkalan', 'Kabupaten Bangkalan, Madura');

-- ------------------------------------------------------------
-- Data awal: User default
-- 
-- ADMIN:
--   Email    : admin@penjamuhandal.id
--   Username : admin
--   Password : admin123
--
-- STAFF:
--   Email    : staff@penjamuhandal.id
--   Username : staff
--   Password : staff123
--
-- (Bisa login dengan email ATAU username)
-- ------------------------------------------------------------
INSERT IGNORE INTO `user` (`id_user`, `id_kota`, `username`, `email`, `pw`, `role`) VALUES
  (1, 1, 'admin', 'admin@penjamuhandal.id',
   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHHG',
   'admin'),
  (2, 2, 'staff', 'staff@penjamuhandal.id',
   '$2a$10$6od4ALfvLrFWQpcvNSpGo.LAUYqPbz3Xlc/YBNcNysCxLdJkL1nhm',
   'staff');

COMMIT;

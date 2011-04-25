-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 29, 2011 at 01:19 AM
-- Server version: 5.1.44
-- PHP Version: 5.3.1



/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: 'addr_grid_test'
--

-- --------------------------------------------------------

--
-- Table structure for table 'points'
--

CREATE TABLE points (
  id INTEGER PRIMARY KEY ASC,
  shapes_id INTEGER,
  ordering INTEGER,
  latitude float NOT NULL,
  longitude float NOT NULL,
  elevation float DEFAULT NULL
);

-- --------------------------------------------------------

--
-- Table structure for table 'shapes'
--

CREATE TABLE shapes (
  id INTEGER PRIMARY KEY ASC,
  latitude_min float NOT NULL DEFAULT '-90',
  latitude_max float NOT NULL DEFAULT '90',
  longitude_min float NOT NULL DEFAULT '-180',
  longitude_max float NOT NULL DEFAULT '180',
  "source" varchar(32) DEFAULT NULL,
  name10 float(6,2) DEFAULT NULL
);

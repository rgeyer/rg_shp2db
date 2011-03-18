-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 16, 2011 at 09:29 PM
-- Server version: 5.1.44
-- PHP Version: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `addr_grid_test`
--

-- --------------------------------------------------------

--
-- Table structure for table `points`
--

CREATE TABLE IF NOT EXISTS `points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shapes_id` int(11) NOT NULL,
  `ordering` int(11) NOT NULL,
  `latitude` float NOT NULL,
  `longitude` float NOT NULL,
  `elevation` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `polygon_id` (`shapes_id`),
  KEY `ordering` (`ordering`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `shapes`
--

CREATE TABLE IF NOT EXISTS `shapes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude_min` float NOT NULL DEFAULT '-90',
  `latitude_max` float NOT NULL DEFAULT '90',
  `longitude_min` float NOT NULL DEFAULT '-180',
  `longitude_max` float NOT NULL DEFAULT '180',
  `source` varchar(32) DEFAULT NULL,
  `name10` float(6,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tract_id` (`name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

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
  KEY `tract_id` (`name10`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Table structure for table `audits`
--

CREATE TABLE IF NOT EXISTS `audits` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ec2_instance_id` varchar(16) DEFAULT NULL,
  `audit_serial` varchar(32) DEFAULT NULL,
  `audit_receive_timeout` int(10) unsigned DEFAULT NULL,
  `work_unit_created_at` timestamp NULL DEFAULT NULL,
  `secs_to_upload` decimal(12,6) unsigned DEFAULT NULL,
  `result` varchar(32) DEFAULT NULL,
  `work_item_id` varchar(48) DEFAULT NULL,
  `queue_url` varchar(256) DEFAULT NULL,
  `s3_log_path` varchar(256) DEFAULT NULL,
  `start_timestamp` timestamp NULL DEFAULT NULL,
  `worker_result` text,
  `s3_downloaded_bytes` int(10) unsigned DEFAULT NULL,
  `result_item_id` varchar(48) DEFAULT NULL,
  `secs_to_download` decimal(12,6) unsigned DEFAULT NULL,
  `end_timestamp` timestamp NULL DEFAULT NULL,
  `s3_uploaded_bytes` int(10) unsigned DEFAULT NULL,
  `secs_to_work` decimal(12,6) unsigned DEFAULT NULL,
  `yaml` text NOT NULL,
  `jobid` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `jobid` (`jobid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_errors`
--

CREATE TABLE IF NOT EXISTS `audit_errors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `audit_id` int(10) unsigned NOT NULL,
  `error` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `audit_id` (`audit_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `outputs`
--

CREATE TABLE IF NOT EXISTS `outputs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `finishtime` timestamp NULL DEFAULT NULL,
  `audit_serial` varchar(32) DEFAULT NULL,
  `audit_receive_timeout` int(10) unsigned DEFAULT NULL,
  `serial` varchar(32) DEFAULT NULL,
  `result` text,
  `starttime` int(10) unsigned DEFAULT NULL,
  `work_item_id` varchar(48) DEFAULT NULL,
  `right_grid_status` varchar(32) DEFAULT NULL,
  `yaml` text NOT NULL,
  `jobid` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobid` (`jobid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `grid_runs`
--

CREATE TABLE IF NOT EXISTS `grid_runs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `jobid` varchar(32) NOT NULL,
  `job_count` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `errors`
--

CREATE TABLE IF NOT EXISTS `errors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `yaml` text NOT NULL,
  `jobid` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

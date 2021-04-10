
CREATE DATABASE `queue_altavas` CHARACTER SET utf8
;
USE `queue_altavas`
;


SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for queue_announcement
-- ----------------------------
DROP TABLE IF EXISTS `queue_announcement`;
CREATE TABLE `queue_announcement` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) DEFAULT NULL,
  `dtfiled` datetime DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `content` text,
  `dtexpiry` datetime DEFAULT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_counter
-- ----------------------------
DROP TABLE IF EXISTS `queue_counter`;
CREATE TABLE `queue_counter` (
  `objid` varchar(50) NOT NULL,
  `code` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `uix_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_counter_section
-- ----------------------------
DROP TABLE IF EXISTS `queue_counter_section`;
CREATE TABLE `queue_counter_section` (
  `counterid` varchar(50) NOT NULL,
  `sectionid` varchar(50) NOT NULL,
  PRIMARY KEY (`counterid`,`sectionid`),
  KEY `fk_queue_counter_section_sectionid` (`sectionid`),
  CONSTRAINT `fk_queue_counter_section_counterid` FOREIGN KEY (`counterid`) REFERENCES `queue_counter` (`objid`),
  CONSTRAINT `fk_queue_counter_section_sectionid` FOREIGN KEY (`sectionid`) REFERENCES `queue_section` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_group
-- ----------------------------
DROP TABLE IF EXISTS `queue_group`;
CREATE TABLE `queue_group` (
  `objid` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_number
-- ----------------------------
DROP TABLE IF EXISTS `queue_number`;
CREATE TABLE `queue_number` (
  `objid` varchar(50) NOT NULL,
  `groupid` varchar(50) NOT NULL,
  `sectionid` varchar(50) NOT NULL,
  `seriesno` int(11) NOT NULL,
  `txndate` datetime NOT NULL,
  `state` varchar(25) NOT NULL,
  `ticketno` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `fk_queue_number_groupid` (`groupid`),
  KEY `fk_queue_number_sectionid` (`sectionid`),
  KEY `ix_ticketno` (`ticketno`) USING BTREE,
  CONSTRAINT `fk_queue_number_groupid` FOREIGN KEY (`groupid`) REFERENCES `queue_group` (`objid`),
  CONSTRAINT `fk_queue_number_sectionid` FOREIGN KEY (`sectionid`) REFERENCES `queue_section` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_number_archive
-- ----------------------------
DROP TABLE IF EXISTS `queue_number_archive`;
CREATE TABLE `queue_number_archive` (
  `objid` varchar(50) NOT NULL,
  `dtfiled` datetime NOT NULL,
  `state` varchar(25) NOT NULL,
  `ticketno` varchar(20) NOT NULL,
  `group_objid` varchar(50) NOT NULL,
  `group_title` varchar(255) DEFAULT NULL,
  `section_objid` varchar(50) NOT NULL,
  `section_title` varchar(255) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  `servedby_objid` varchar(50) DEFAULT NULL,
  `servedby_name` varchar(180) DEFAULT NULL,
  `counter_objid` varchar(50) DEFAULT NULL,
  `counter_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `ix_dtfiled` (`dtfiled`),
  KEY `ix_ticketno` (`ticketno`),
  KEY `ix_group_objid` (`group_objid`),
  KEY `ix_section_objid` (`section_objid`),
  KEY `ix_startdate` (`startdate`),
  KEY `ix_enddate` (`enddate`),
  KEY `ix_servedby_objid` (`servedby_objid`),
  KEY `ix_counter_objid` (`counter_objid`) USING BTREE,
  KEY `ix_counter_code` (`counter_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_number_counter
-- ----------------------------
DROP TABLE IF EXISTS `queue_number_counter`;
CREATE TABLE `queue_number_counter` (
  `objid` varchar(50) NOT NULL,
  `counterid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `uix_counterid` (`counterid`),
  CONSTRAINT `fk_queue_number_counter` FOREIGN KEY (`counterid`) REFERENCES `queue_counter` (`objid`),
  CONSTRAINT `fk_queue_number_counter_objid` FOREIGN KEY (`objid`) REFERENCES `queue_number` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for queue_section
-- ----------------------------
DROP TABLE IF EXISTS `queue_section`;
CREATE TABLE `queue_section` (
  `objid` varchar(50) NOT NULL,
  `groupid` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `currentseries` int(11) NOT NULL,
  `prefix` varchar(1) DEFAULT NULL,
  `sortorder` int(11) NOT NULL,
  `dtexpiry` datetime DEFAULT NULL,
  `lockid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  KEY `fk_queue_section_groupid` (`groupid`),
  KEY `ix_dtexpiry` (`dtexpiry`),
  CONSTRAINT `fk_queue_section_groupid` FOREIGN KEY (`groupid`) REFERENCES `queue_group` (`objid`),
  CONSTRAINT `queue_section_ibfk_1` FOREIGN KEY (`groupid`) REFERENCES `queue_group` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

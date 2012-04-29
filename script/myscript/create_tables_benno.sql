DROP TABLE IF EXISTS `label`;
CREATE TABLE `label` (
    `id` INTEGER unsigned NOT NULL auto_increment,
    `d11sig` varchar(40) collate utf8_unicode_ci NOT NULL default '',
    `d11mcopyno` int(11) default NULL,
    `d11tag` datetime NOT NULL default '0000-00-00 00:00:00',
    `d11zweig` smallint(6) default NULL,
    `d11titlecatkey` int(11) default NULL,
    `d01gsi` varchar(27) collate utf8_unicode_ci default NULL,
    `d01entl` varchar(1) collate utf8_unicode_ci default NULL,
    `d01mtyp` smallint(6) default NULL,
    `type` varchar(5) collate utf8_unicode_ci default NULL,
    `printed` datetime default NULL,
    `deleted` datetime default NULL,
    PRIMARY KEY  (`id`),
    UNIQUE KEY `d11sig` (`d11sig`,`d11tag`)
) ENGINE=MyISAM AUTO_INCREMENT=262143 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE  IF EXISTS users;
CREATE TABLE users (
    id            INTEGER unsigned NOT NULL auto_increment,
    username      VARCHAR(255),
    password      VARCHAR(255),
    password_expires TIMESTAMP,
    email_address VARCHAR(255),
    first_name    VARCHAR(255),
    last_name     VARCHAR(255),
    active        INTEGER,
    PRIMARY KEY (id),
    UNIQUE (email_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS printers;
CREATE TABLE printers (
    id          INTEGER unsigned NOT NULL auto_increment,
    ip_address  VARCHAR(15),
    pcname      VARCHAR(100),
    room        VARCHAR(100),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS role;
CREATE TABLE role (
    id   INTEGER unsigned NOT NULL auto_increment,
    role VARCHAR(255),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS user_role;
CREATE TABLE user_role (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


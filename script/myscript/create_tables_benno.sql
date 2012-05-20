DROP TABLE IF EXISTS labels;
CREATE TABLE `labels` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE  IF EXISTS users;
CREATE TABLE users (
    id            INTEGER unsigned NOT NULL auto_increment,
    username      VARCHAR(255) UNIQUE,
    password      VARCHAR(255),
    password_expires TIMESTAMP,
    email_address VARCHAR(255) UNIQUE,
    first_name    VARCHAR(255),
    last_name     VARCHAR(255),
    active        INTEGER,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS printers;
CREATE TABLE printers (
    id          INTEGER unsigned NOT NULL auto_increment,
    ip_address  VARCHAR(15),
    pcname      VARCHAR(100),
    room        VARCHAR(100),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
    id   INTEGER unsigned NOT NULL auto_increment,
    name VARCHAR(255),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS users_roles;
CREATE TABLE users_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS labelgroups;
CREATE TABLE labelgroups (
   id INTEGER unsigned NOT NULL auto_increment,
   urlname varchar(50) UNIQUE,
   shortname VARCHAR(50) UNIQUE,
   name VARCHAR(255) UNIQUE,
   search TEXT,
   PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
    id            INTEGER unsigned NOT NULL auto_increment,
    address       VARCHAR(255) UNIQUE,
    hostname      VARCHAR(255) UNIQUE,
    room          VARCHAR(255),  
    active        INTEGER,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS clients_roles;
CREATE TABLE clients_roles (
    client_id INTEGER REFERENCES clients(id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (client_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


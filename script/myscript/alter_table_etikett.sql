drop table labels;
alter table etikett rename labels;
alter table labels change typ type varchar(5) collate utf8_unicode_ci default NULL;
alter table labels change gedruckt printed datetime default NULL;
alter table labels add deleted datetime default NULL;


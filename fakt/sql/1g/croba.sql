
GRANT ALL PRIVILEGES ON *.* TO ODBC@'%'
           IDENTIFIED BY '' WITH GRANT OPTION;
flush privileges;

create table croba (
  id        int  AUTO_INCREMENT PRIMARY KEY,
  idj       varchar(10),
  idrobafmk varchar(10),
  stanjem   decimal(18,3),
  stanjev   decimal(18,3),
  ulazm     decimal(18,3),
  ulazv     decimal(18,3),
  realm     decimal(18,3),
  realv     decimal(18,3),
  datumm    date,
  datumv    date
);
CREATE UNIQUE INDEX croba_idrfmk  on croba(idrobafmk);

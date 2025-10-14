-- Your SQL goes here
CREATE TABLE keyword_specialtys (
    uuid BINARY(16) PRIMARY KEY,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NULL,
    keyword_uuid BINARY(16) not null,
	specialty_uuid BINARY(16) not null,

    foreign key (keyword_uuid) references keywords(uuid),
	foreign key (specialty_uuid) references specialtys(uuid)
);

ALTER TABLE `keyword_specialtys` ADD UNIQUE `rome_nafs_unique_keyword_id_specialty_id` (`keyword_uuid`, `specialty_uuid`);

CREATE TABLE IF NOT EXISTS `mc_magixslideshow` (
    `id_slide` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `img_slide` VARCHAR(255) NOT NULL,
    `order_slide` INT UNSIGNED NOT NULL DEFAULT 0,
    `date_register` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_slide`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mc_magixslideshow_content` (
    `id_slide_content` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_slide` INT UNSIGNED NOT NULL,
    `id_lang` INT UNSIGNED NOT NULL,
    `title_slide` VARCHAR(255) NOT NULL,
    `desc_slide` TEXT,
    `link_url_slide` VARCHAR(255) DEFAULT NULL,
    `link_label_slide` VARCHAR(255) DEFAULT NULL,
    `link_title_slide` VARCHAR(255) DEFAULT NULL,
    `blank_slide` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    `link2_url_slide` VARCHAR(255) DEFAULT NULL,
    `link2_label_slide` VARCHAR(255) DEFAULT NULL,
    `link2_title_slide` VARCHAR(255) DEFAULT NULL,
    `blank2_slide` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    `published_slide` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id_slide_content`),
    KEY `id_lang` (`id_lang`),
    KEY `id_slide` (`id_slide`),
    CONSTRAINT `fk_magixslideshow_content_id`
    FOREIGN KEY (`id_slide`)
    REFERENCES `mc_magixslideshow` (`id_slide`)
    ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELETE FROM `mc_config_img` WHERE `module_img` = 'magixslideshow';

INSERT INTO `mc_config_img` (`module_img`, `attribute_img`, `width_img`, `height_img`, `type_img`, `prefix_img`, `resize_img`) VALUES
('magixslideshow', 'magixslideshow', 768, 320, 'small', 's', 'adaptive'),
('magixslideshow', 'magixslideshow', 1440, 600, 'medium', 'm', 'adaptive'),
('magixslideshow', 'magixslideshow', 1920, 800, 'large', 'l', 'adaptive');
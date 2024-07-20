CreateThread(function()
    -- Creating the 'mailboxes' table if it doesn't already exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `mailboxes` (
            `char_identifier` varchar(255) NOT NULL,
            `mailbox_id` int AUTO_INCREMENT,
            `first_name` varchar(255) DEFAULT NULL,
            `last_name` varchar(255) DEFAULT NULL,
            PRIMARY KEY (`mailbox_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Creating the 'mailbox_messages' table if it doesn't already exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `mailbox_messages` (
            `from_char` varchar(255) NOT NULL,
            `to_char` varchar(255) NOT NULL,
            `from_name` varchar(255) NOT NULL,
            `message` text NOT NULL,
            `subject` varchar(255) DEFAULT NULL,
            `location` varchar(255) DEFAULT NULL,
            `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
            `id` int AUTO_INCREMENT,
            `eta_timestamp` bigint DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Ensure the transaction is committed to save the changes
    MySQL.query.await("COMMIT;")

    -- Print a success message to console
    print("\x1b[32mDatabase tables for\x1b[0m \x1b[34m[`isee_mailbox`]\x1b[0m \x1b[32mcreated or updated successfully.\x1b[0m")
end)

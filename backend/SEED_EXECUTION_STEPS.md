# Seed Execution Steps for MySQL Container

Follow these steps to execute the seed files in the MySQL container:

---

## 1. Verify MySQL Container is Running
Run the following command to check if the MySQL container is active:

```bash
docker ps
```

If the container is not running, start it with:

```bash
docker-compose up -d
```

---

## 2. Copy Seed Files to the Container
Use the following commands to copy the seed files from the host to the MySQL container:

```bash
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_backgrounds.sql <mysql-container-name>:/seed_backgrounds.sql
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_feats.sql <mysql-container-name>:/seed_feats.sql
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_sc_features_p1.sql <mysql-container-name>:/seed_sc_features_p1.sql
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_sc_features_p2.sql <mysql-container-name>:/seed_sc_features_p2.sql
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_subclasses.sql <mysql-container-name>:/seed_subclasses.sql
docker cp /home/alexandre.barbeito/GestorPersonajesDND/backend/backups/seed_subraces.sql <mysql-container-name>:/seed_subraces.sql
```

Replace `<mysql-container-name>` with the name of your MySQL container (you can find it using `docker ps`).

---

## 3. Access the MySQL Container
Connect to the MySQL container using:

```bash
docker exec -it <mysql-container-name> bash
```

---

## 4. Connect to the MySQL Client
Inside the container, log in to the MySQL client:

```bash
mysql -u <username> -p
```

Replace `<username>` with the MySQL username (e.g., `root`). Enter the password when prompted.

---

## 5. Select the Database
Choose the database where you want to load the seeds:

```sql
USE <database_name>;
```

Replace `<database_name>` with the name of your database.

---

## 6. Execute the Seed Files
Run the following commands to execute the seed files in the correct order:

```sql
SOURCE /seed_backgrounds.sql;
SOURCE /seed_feats.sql;
SOURCE /seed_sc_features_p1.sql;
SOURCE /seed_sc_features_p2.sql;
SOURCE /seed_subclasses.sql;
SOURCE /seed_subraces.sql;
```

---

## 7. Verify the Data
After executing the seeds, verify that the data has been loaded correctly. For example:

```sql
SHOW TABLES;
SELECT * FROM <table_name>;
```

Replace `<table_name>` with the name of a relevant table.

---

## 8. Exit the Container
When you are done, exit the MySQL client and the container:

```bash
exit
```
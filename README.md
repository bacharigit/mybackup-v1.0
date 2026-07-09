# Introduction

A lightweight Docker image based on **Alpine Linux** that creates compressed (`.tar.gz`) backups of a directory. The image supports automatic scheduled backups using `cron` and automatically removes backup archives older than 30 days.


# Project Structure

```text
.
├── Dockerfile
├── backup.sh
└── README.md
```

* **Dockerfile** – Builds the Docker image.
* **backup.sh** – Creates the backup archive and removes old backups.
* **README.md** – Project documentation.

---

# Build the Image

Build the Docker image from the project directory:

```bash
docker build -t mybackup:v1.0 .
```

Verify that the image was created:

```bash
docker images
```

---

# Prepare the Host

Create the directories used by the container:

```bash
mkdir -p $HOME/data
mkdir -p $HOME/backups
```

* **$HOME/data** contains the files to back up.
* **$HOME/backups** stores the generated backup archives.

Example:

```text
$HOME
├── data
│   ├── report.txt
│   └── notes.txt
│
└── backups
```

---

# Run the Backup

Run the container:

```bash
docker run --rm \
    -v $HOME/data:/data:ro \
    -v $HOME/backups:/backup \
    mybackup:v1.0
```

The container performs the following steps:

1. Reads the files from `/data`.
2. Creates a compressed `.tar.gz` archive with a timestamp, for example:
backup-2026-07-09_18-30-25.tar.gz
3. Saves the archive in `/backup`.
4. Removes backup archives older than 30 days.
5. Exits automatically.
6. Docker removes the container because of the `--rm` option.

The backup archives are stored on the host in:

```text
$HOME/backups

They remain available even after the backup container exits because they are stored on the host through a Docker bind mount. Backup archives older than 30 days are removed only when the cleanup step in backup.sh is executed.


# Schedule Automatic Backups

To run the backup automatically every day at 08:00 and 20:00, edit your crontab:

```bash
crontab -e
```

Add the following entry:

```cron
0 8,20 * * * /usr/bin/docker run --rm -v /home/<username>/data:/data:ro -v /home/<username>/backups:/backup mybackup:v2.0
```

Replace `<username>` with your Linux username.

This schedule runs the backup every day at:

* **08:00**
* **20:00**


**Note:** The cron job runs on the **host machine**, not inside the container. At each scheduled time, cron starts a new backup container. The container performs the backup, removes backup archives older than 30 days, exits, and is automatically removed because of the `--rm` option.

each execution creates a new container, performs the backup, removes old backups, and exits.

# Automatic Cleanup

At the end of `backup.sh`, the following command removes old backup archives:

```sh
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
```

This command:

* Searches the backup directory.
* Finds files ending with `.tar.gz`.
* Deletes files older than **30 days**.

This helps prevent the backup directory from growing indefinitely.



# Inspect the Container

To open a shell inside the container:

```bash
docker run --rm -it \
    --entrypoint /bin/sh \
    -v $HOME/data:/data:ro \
    -v $HOME/backups:/backup \
    mybackup:v1.0
```

Useful commands:

```sh
ls /
ls /data
ls /backup
cat /backup.sh
```

To execute the backup script manually:

```sh
/backup.sh
```

Exit the shell:

```sh
exit
```

---

# Notes

* Based on **Alpine Linux** for a small image size.
*  `/data` is mounted as **read-only** to prevent the backup container from modifying the source files.
* `/backup` is mounted as **read-write** so backup archives can be created.
* Docker automatically creates the `/data` and `/backup` mount points when the container starts.
* The container is designed to work well with scheduled tasks such as `cron`.
* Backup archives are stored on the host, so they remain available even after the backup container exits and is removed. During each backup run, the container also removes backup archives older than 30 days to help keep the backup directory clean.

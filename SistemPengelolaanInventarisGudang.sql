	--============ KELOMPOK 04 SISTEM BASIS DATA ============--
	--======== SISTEM PENGELOLAAN INVENTARIS GUDANG ========--
	-- Tabel User
	CREATE TABLE Pengguna (
	    id_user SERIAL PRIMARY KEY,
	    username VARCHAR(50) NOT NULL UNIQUE,
	    password VARCHAR(255) NOT NULL,
	    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Pemasok', 'Toko'))
	);
	
	-- Tabel ProdukEcommerce
	CREATE TABLE ProdukEcommerce (
	    id_produk_ecommerce SERIAL PRIMARY KEY,
	    nama_produk VARCHAR(100) NOT NULL,
	    harga DOUBLE PRECISION NOT NULL
	);
	
	-- Tabel Produk
	CREATE TABLE Produk (
	    id_produk SERIAL PRIMARY KEY,
	    nama_produk VARCHAR(100) NOT NULL,
	    kategori VARCHAR(50) NOT NULL CHECK (kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')),
	    stok INT NOT NULL,
	    harga_satuan DOUBLE PRECISION NOT NULL,
	    id_produk_ecommerce INT,
	    FOREIGN KEY (id_produk_ecommerce) REFERENCES ProdukEcommerce (id_produk_ecommerce) ON DELETE SET NULL
	);
	
	-- Tabel Transaksi
	CREATE TABLE Transaksi (
	    id_transaksi SERIAL PRIMARY KEY,
	    tanggal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	    tipe VARCHAR(20) NOT NULL CHECK (tipe IN ('Masuk', 'Keluar', 'Produk Baru')),
	    stok INT,
		harga_satuan DOUBLE PRECISION NOT NULL,
		total_harga DOUBLE PRECISION NOT NULL,
	    id_produk INT,
	    id_user INT,
	    FOREIGN KEY (id_produk) REFERENCES Produk (id_produk) ON DELETE SET NULL,
	    FOREIGN KEY (id_user) REFERENCES Pengguna (id_user) ON DELETE SET NULL
	);
	
	-- Insert data ke tabel Pengguna
	INSERT INTO Pengguna (username, password, role) VALUES
	('admin3', 'password1', 'Admin'),
	('admin2', 'password2', 'Admin'),
	('toko1', 'password3', 'Toko'),
	('toko2', 'password4', 'Toko'),
	('toko3', 'password5', 'Toko'),
	('pemasok1', 'password6', 'Pemasok'),
	('pemasok2', 'password7', 'Pemasok'),
	('pemasok3', 'password8', 'Pemasok');
	
	-- Insert data ke tabel Produk
	INSERT INTO Produk (nama_produk, kategori, stok, harga_satuan) VALUES
	('Laptop ABC', 'Elektronik', 10, 15000000),
	('Smartphone XYZ', 'Elektronik', 20, 8000000),
	('Kamera 123', 'Elektronik', 15, 5000000),
	('Kaos Polos', 'Pakaian', 50, 50000),
	('Roti Gandum', 'Makanan', 100, 20000),
	('TV Ultra HD', 'Elektronik', 8, 12000000),
	('Meja Belajar', 'Lainnya', 25, 750000),
	('Jus Jeruk', 'Minuman', 200, 15000),
	('Sepatu Lari', 'Pakaian', 30, 300000),
	('Beras Premium', 'Makanan', 500, 100000);
	
	-- Stored Procedure untuk tambah produk
	CREATE OR REPLACE PROCEDURE tambah_produk(
	    p_nama_produk VARCHAR(100),
	    p_kategori VARCHAR(50),
	    p_harga DOUBLE PRECISION,
	    p_stok INT,
	    p_id_admin INT
	)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    role_pengguna VARCHAR(20);
	BEGIN
	    -- Periksa role pengguna berdasarkan p_id_admin
	    SELECT role INTO role_pengguna
	    FROM Pengguna
	    WHERE id_user = p_id_admin;
	
	    -- Validasi apakah role adalah Admin
	    IF role_pengguna IS NULL THEN
	        RAISE EXCEPTION 'Pengguna dengan ID % tidak ditemukan.', p_id_admin;
	    ELSIF role_pengguna != 'Admin' THEN
	        RAISE EXCEPTION 'Hanya pengguna dengan role Admin yang dapat menambahkan produk.';
	    END IF;
	
	    -- Validasi kategori
	    IF NOT (p_kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')) THEN
	        RAISE EXCEPTION 'Kategori tidak valid.';
	    END IF;
	
	    -- Tambahkan produk ke tabel Produk
	    INSERT INTO Produk (nama_produk, kategori, harga_satuan, stok)
	    VALUES (p_nama_produk, p_kategori, p_harga, p_stok);
	
	    -- Catat transaksi untuk produk baru
	    INSERT INTO Transaksi (tipe, stok, harga_satuan, total_harga, id_produk, id_user)
	    VALUES ('Produk Baru', p_stok, p_harga, p_stok * p_harga, currval('produk_id_produk_seq'), p_id_admin);
	END;
	$$;
	
	-- Hak Akses
	GRANT EXECUTE ON PROCEDURE tambah_produk TO admin_role;
	
	-- test
	CALL tambah_produk('Tas Kulit', 'Lainnya', 250000, 5, 9); 
	
	CALL tambah_produk('Monitor LED', 'Elektronik', 2500000, 10, 1); 
	
	SELECT * FROM Transaksi;
	
	SELECT * FROM Produk;

	-- Fungsi untuk Menambah Stok oleh Pemasok
	CREATE OR REPLACE PROCEDURE tambah_stok(
	    p_id_produk INT,
	    p_jumlah INT,
	    p_id_pemasok INT
	)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    role_pengguna VARCHAR(20);
	BEGIN
	    -- Periksa role pengguna berdasarkan p_id_pemasok
	    SELECT role INTO role_pengguna
	    FROM Pengguna
	    WHERE id_user = p_id_pemasok;
	
	    -- Validasi apakah role adalah Pemasok
	    IF role_pengguna IS NULL THEN
	        RAISE EXCEPTION 'Pengguna dengan ID % tidak ditemukan.', p_id_pemasok;
	    ELSIF role_pengguna != 'Pemasok' THEN
	        RAISE EXCEPTION 'Hanya pengguna dengan role Pemasok yang dapat menambah stok.';
	    END IF;
	
	    -- Validasi jumlah stok
	    IF p_jumlah <= 0 THEN
	        RAISE EXCEPTION 'Jumlah stok yang ditambahkan harus lebih besar dari 0';
	    END IF;
	
	    -- Perbarui stok produk
	    UPDATE Produk
	    SET stok = stok + p_jumlah
	    WHERE id_produk = p_id_produk;
	
	    -- Catat ke tabel Transaksi
	    INSERT INTO Transaksi (tipe, stok, harga_satuan, total_harga, id_produk, id_user)
	    VALUES ('Masuk', p_jumlah, (SELECT harga_satuan FROM Produk WHERE id_produk = p_id_produk),
	            (SELECT harga_satuan FROM Produk WHERE id_produk = p_id_produk) * p_jumlah,
	            p_id_produk, p_id_pemasok);
	END;
	$$;

	GRANT EXECUTE ON PROCEDURE tambah_stok TO pemasok_role;

	CALL tambah_stok(6, 5, 7); 

	select * from transaksi;
	
	-- Stored Procedure untuk mengurangi stok
	CREATE OR REPLACE PROCEDURE kurangi_stok(
	    p_id_produk INT,
	    p_jumlah INT,
	    p_id_toko INT
	)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    stok_sekarang INT;
	    produk_harga_satuan DOUBLE PRECISION;
	    total_harga DOUBLE PRECISION;
	    role_pengguna VARCHAR(20);
	BEGIN
	    -- Validasi jumlah stok yang dikurangi harus lebih besar dari 0
	    IF p_jumlah <= 0 THEN
	        RAISE EXCEPTION 'Jumlah stok yang dikurangi harus lebih besar dari 0';
	    END IF;
	
	    -- Ambil stok produk saat ini dan harga satuan
	    SELECT stok, harga_satuan INTO stok_sekarang, produk_harga_satuan
	    FROM Produk
	    WHERE id_produk = p_id_produk;
	
	    -- Periksa apakah stok mencukupi sebelum pengurangan
	    IF stok_sekarang IS NULL THEN
	        RAISE EXCEPTION 'Produk dengan ID % tidak ditemukan.', p_id_produk;
	    ELSIF stok_sekarang < p_jumlah THEN
	        RAISE EXCEPTION 'Stok tidak mencukupi untuk pengurangan';
	    END IF;
	
	    -- Ambil role toko berdasarkan p_id_toko
	    SELECT role INTO role_pengguna
	    FROM Pengguna
	    WHERE id_user = p_id_toko;
	
	    -- Validasi apakah role adalah Toko
	    IF role_pengguna IS NULL THEN
	        RAISE EXCEPTION 'Pengguna dengan ID % tidak ditemukan.', p_id_toko;
	    ELSIF role_pengguna != 'Toko' THEN
	        RAISE EXCEPTION 'Hanya pengguna dengan role Toko yang dapat mengurangi stok.';
	    END IF;
	
	    -- Hitung total harga dari produk yang dikeluarkan
	    total_harga := p_jumlah * produk_harga_satuan;
	
	    -- Perbarui stok produk, pastikan stok tidak negatif
	    UPDATE Produk
	    SET stok = stok - p_jumlah
	    WHERE id_produk = p_id_produk
	    RETURNING stok INTO stok_sekarang;
	
	    IF stok_sekarang < 0 THEN
	        RAISE EXCEPTION 'Kesalahan logika: stok menjadi negatif';
	    END IF;
	
	    -- Catat transaksi ke tabel Transaksi
	    INSERT INTO Transaksi (tipe, stok, harga_satuan, total_harga, id_produk, id_user, tanggal)
	    VALUES ('Keluar', p_jumlah, produk_harga_satuan, total_harga, p_id_produk, p_id_toko, CURRENT_TIMESTAMP);
	
	    -- Notifikasi sukses
	    RAISE NOTICE 'Stok produk % telah dikurangi sebanyak % unit.', p_id_produk, p_jumlah;
	END;
	$$;
	
	-- Hak Akses
	GRANT EXECUTE ON PROCEDURE kurangi_stok TO toko_role;
	
	-- Contoh Penggunaan
	CALL kurangi_stok(11, 1, 4); -- Berhasil
	CALL kurangi_stok(4, 2, 1); -- Error karena role bukan Toko
	
	select * from produk;

	-- Cursor untuk memantau stok hampir habis dan yang sudah habis
	DO $$
	DECLARE
	    stok_cursor CURSOR FOR
	        SELECT id_produk, nama_produk, stok
	        FROM Produk
	        WHERE stok <= 10; -- Kondisi stok hampir habis
	    stok_data RECORD;
	BEGIN
	    -- Membuka cursor
	    OPEN stok_cursor;
	
	    -- Iterasi melalui data cursor
	    LOOP
	        FETCH stok_cursor INTO stok_data;
	        EXIT WHEN NOT FOUND;
	
	        IF stok_data.stok = 0 THEN
	            RAISE NOTICE 'Produk % (ID: %) telah habis.', stok_data.nama_produk, stok_data.id_produk;
	        ELSE
	            RAISE NOTICE 'Produk % (ID: %) hampir habis dengan stok % unit.', stok_data.nama_produk, stok_data.id_produk, stok_data.stok;
	        END IF;
	    END LOOP;
	
	    -- Menutup cursor
	    CLOSE stok_cursor;
	END $$;

	-- Trigger untuk mencegah stok bernilai negatif
	CREATE OR REPLACE FUNCTION cek_stok_negatif()
	RETURNS TRIGGER AS $$
	BEGIN
	    -- Pengecekan jika stok akan menjadi negatif
	    IF NEW.stok < 0 THEN
	        RAISE EXCEPTION 'Pengurangan stok tidak dapat dilakukan karena stok akan menjadi negatif.';
	    END IF;
	
	    -- Jika stok valid, lanjutkan proses
	    RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;
	
	CREATE TRIGGER trigger_cek_stok_negatif
	BEFORE UPDATE ON Produk
	FOR EACH ROW
	WHEN (OLD.stok <> NEW.stok)
	EXECUTE FUNCTION cek_stok_negatif();
	
	-- Mencoba mengurangi stok hingga bernilai negatif, bisa menggunakan procedure yang tadi
	-- di pemanggilan fungsi ini, stok produk ber id 7 memang sudah sebanyak 10 itu sebabnya bisa.
	CALL kurangi_stok(7, 15, 3); 
	
	SELECT * FROM Produk;

	-- Prosedur untuk mencari produk
	CREATE OR REPLACE PROCEDURE SEARCH_PRODUK(
	    p_keyword VARCHAR(100)
	)
	LANGUAGE plpgsql
	AS $$
	DECLARE
	    produk RECORD; -- Variabel untuk menyimpan hasil query
	    produk_ditemukan BOOLEAN := FALSE; -- Variabel untuk melacak apakah produk ditemukan
	BEGIN
	    -- Pencarian produk berdasarkan nama, kategori, atau harga
	    FOR produk IN (
	        SELECT id_produk, nama_produk, kategori, harga_satuan, stok
	        FROM Produk
	        WHERE nama_produk LIKE '%' || p_keyword || '%'
	           OR kategori LIKE '%' || p_keyword || '%'
	           OR (p_keyword ~ '^[0-9]+(\\.[0-9]+)?$' AND harga_satuan = CAST(p_keyword AS DOUBLE PRECISION)) -- Cek jika p_keyword adalah angka
	    )
	    LOOP
	        -- Menampilkan hasil pencarian produk
	        RAISE NOTICE 'ID: % | Nama: % | Kategori: % | Harga: Rp % | Stok: % ', produk.id_produk, produk.nama_produk, produk.kategori, produk.harga_satuan, produk.stok;
	        produk_ditemukan := TRUE; -- Tandai bahwa produk ditemukan
	    END LOOP;
	
	    -- Jika tidak ada produk ditemukan, tampilkan peringatan
	    IF NOT produk_ditemukan THEN
	        RAISE NOTICE 'Peringatan: Tidak ada produk ditemukan untuk kata kunci: %', p_keyword;
	    END IF;
	END;
	$$;
	
	CALL SEARCH_PRODUK('Beras');

	CREATE VIEW TransaksiTerakhir AS
	SELECT t.id_transaksi, t.tipe, t.stok, t.harga_satuan, t.total_harga, t.tanggal, p.nama_produk
	FROM Transaksi t
	JOIN Produk p ON t.id_produk = p.id_produk
	ORDER BY t.tanggal DESC;
	
	SELECT * FROM TransaksiTerakhir;
	
	CREATE VIEW TransaksiPemasok AS
	SELECT t.id_transaksi, t.tipe, t.stok, t.harga_satuan, t.total_harga, p.nama_produk
	FROM Transaksi t
	JOIN Produk p ON t.id_produk = p.id_produk
	WHERE t.id_user IN (SELECT id_user FROM Pengguna WHERE role = 'Pemasok');
	
	select * from TransaksiPemasok
	
	CREATE VIEW TransaksiToko AS
	SELECT t.id_transaksi, t.tipe, t.stok, t.harga_satuan, t.total_harga, p.nama_produk
	FROM Transaksi t
	JOIN Produk p ON t.id_produk = p.id_produk
	WHERE t.id_user IN (SELECT id_user FROM Pengguna WHERE role = 'Toko');
	
	select * from TransaksiToko;
		
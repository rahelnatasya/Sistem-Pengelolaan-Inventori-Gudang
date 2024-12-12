# README: Sistem Pengelolaan Inventaris Gudang

## Deskripsi

Sistem ini adalah aplikasi pengelolaan inventaris gudang yang dirancang untuk memfasilitasi pengelolaan produk, transaksi, dan pengguna dalam sebuah gudang. Sistem ini menggunakan basis data relasional yang memungkinkan pengguna untuk melakukan operasi seperti menambah produk, menambah stok, mengurangi stok, dan melakukan pencarian produk.

## Tabel dan Struktur Basis Data

### 1. Tabel `Pengguna`

- **`id_user`**: ID unik untuk setiap pengguna (SERIAL, PRIMARY KEY)
- **`username`**: Nama pengguna (VARCHAR)
- **`password`**: Kata sandi pengguna (VARCHAR)
- **`role`**: Peran pengguna (VARCHAR) - dapat berupa 'Admin', 'Pemasok', atau 'Toko'.

### 2. Tabel `ProdukEcommerce`

- **`id_produk_ecommerce`**: ID unik untuk produk ecommerce (SERIAL, PRIMARY KEY)
- **`nama_produk`**: Nama produk (VARCHAR)
- **`harga`**: Harga produk (DOUBLE PRECISION)

### 3. Tabel `Produk`

- **`id_produk`**: ID unik untuk setiap produk (SERIAL, PRIMARY KEY)
- **`nama_produk`**: Nama produk (VARCHAR)
- **`kategori`**: Kategori produk (VARCHAR) - dapat berupa 'Elektronik', 'Pakaian', 'Makanan', 'Minuman', atau 'Lainnya'.
- **`stok`**: Jumlah stok produk (INT)
- **`harga_satuan`**: Harga per unit produk (DOUBLE PRECISION)
- **`id_produk_ecommerce`**: Relasi ke tabel `ProdukEcommerce` (FOREIGN KEY)

### 4. Tabel `Transaksi`

- **`id_transaksi`**: ID unik untuk setiap transaksi (SERIAL, PRIMARY KEY)
- **`tanggal`**: Tanggal dan waktu transaksi (TIMESTAMP)
- **`tipe`**: Tipe transaksi (VARCHAR) - dapat berupa 'Masuk', 'Keluar', atau 'Produk Baru'.
- **`stok`**: Jumlah stok yang terlibat dalam transaksi (INT)
- **`harga_satuan`**: Harga per unit pada saat transaksi (DOUBLE PRECISION)
- **`total_harga`**: Total harga transaksi (DOUBLE PRECISION)
- **`id_produk`**: Relasi ke tabel `Produk` (FOREIGN KEY)
- **`id_user`**: Relasi ke tabel `Pengguna` (FOREIGN KEY)

## Prosedur dan Fungsi

### Prosedur

1. **tambah_produk**: Menambah produk baru ke dalam tabel `Produk` dan mencatat transaksi.
2. **tambah_stok**: Menambah stok untuk produk yang ada, khusus untuk pengguna dengan peran 'Pemasok'.
3. **kurangi_stok**: Mengurangi stok untuk produk yang ada, khusus untuk pengguna dengan peran 'Toko'.
4. **SEARCH_PRODUK**: Mencari produk berdasarkan nama, kategori, atau harga.

### Trigger

- **cek_stok_negatif**: Mencegah pengurangan stok yang akan menghasilkan stok negatif.

## Views

1. **TransaksiTerakhir**: Menampilkan daftar transaksi terbaru.
2. **TransaksiPemasok**: Menampilkan transaksi yang dilakukan oleh pengguna dengan peran 'Pemasok'.
3. **TransaksiToko**: Menampilkan transaksi yang dilakukan oleh pengguna dengan peran 'Toko'.

## Hak Akses

Hak akses diberikan kepada peran tertentu untuk mengeksekusi prosedur yang relevan, memastikan bahwa hanya pengguna dengan hak yang sesuai yang dapat melakukan tindakan tertentu.

## Contoh Penggunaan

- Menambahkan produk baru:
  ```sql
  CALL tambah_produk('Tas Kulit', 'Lainnya', 250000, 5, 9);

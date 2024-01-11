# cloudflare-ufw
Setup IP Range Cloudflare cho UFW.

### Chuẩn bị
Kiểm tra UFW để chắc chắn UFW chưa được enabled, chạy lệnh sau.

```sudo ufw status verbose```

Nếu kết quả trả về là ```Status: inactive``` thì có thể bỏ qua bước này, nếu không hãy chạy lệnh sau.

```sudo ufw disable```

Chạy lệnh sau để reset UFW rules về mặc định.

```sudo ufw reset```

Chạy lệnh sau để thiết lập mặc định chặn kết nối đến và cho phép kết nối đi.

```sudo ufw default deny incoming```  
```sudo ufw default allow outgoing```

Để tránh sự cố xảy ra khi thiết lập, hãy thêm 2 lệnh sau trước khi tiếp tục. Đầu tiên là allow localhost.

```sudo ufw allow from 192.168.1.0/24```

Tiếp theo là allow SSH.

```sudo ufw allow ssh```

Bây giờ tới lúc enable firewall, chạy lệnh sau.

```sudo ufw enable```

Bạn sẽ nhận được 1 cảnh báo như sau "command may disrupt existing ssh connections." Đây là điều bình thường vì đã allows SSH, nhập Y để tiếp tục. 
Để kiểm tra trạng thái UFW, chạy lệnh ```sudo ufw status verbose``` .

### Tiến hành cài đặt

Mở thư mục /root

```cd /root```

Tự động download, phân quyền và cài đặt

```curl -sO https://raw.githubusercontent.com/Paul-Reed/cloudflare-ufw/master/cloudflare-ufw.sh && chmod +x cloudflare-ufw.sh && ./cloudflare-ufw.sh```

Sript này sẽ tự động tải các dải IPv4 và IPv6 hiện tại và cài đặt vào UFW. Để kiểm tra rules đã được added thành công, chạy lệnh ```sudo ufw status verbose```

### Lên lịch cập nhật tự động

Cập nhật các dải IP từ Cloudflare hàng tuần. Chạy lệnh sau để mở crontab.

```sudo crontab -e```

Thêm dòng sau vào

```0 0 * * 1 /root/cloudflare-ufw.sh > /dev/null 2>&1```

**HOẶC**

Nếu sử dụng node-red, chỉ cần thêm add ```sudo /root/cloudflare-ufw.sh``` để 'exec node'  và chạy hàng tuần.

### Các lệnh UFW khác

#### Xóa từng rule theo number
Liệt kê danh sách tất cả các rules hiện tại, chạy lệnh.
```sudo ufw status numbered```

Xóa rule theo number, ví dụ xóa rule có number bằng 34.
```sudo ufw delete 34```

Concept gốc [được phát triển bởi Leow Kah Man](https://www.leowkahman.com/2016/05/02/automate-raspberry-pi-ufw-allow-cloudflare-inbound/).

# Enhanced Notes App

Ứng dụng ghi chú tiên tiến được xây dựng bằng Flutter và SQLite với đầy đủ tính năng quản lý ghi chú.

## ✨ Tính năng chính

### 📝 Quản lý ghi chú CRUD

- ✅ Tạo, xem, sửa, xóa ghi chú
- ✅ Tiêu đề, nội dung, ngày tạo/chỉnh sửa
- ✅ Trạng thái hoàn thành/chưa hoàn thành
- ✅ Đánh dấu yêu thích

### 🏷️ Gắn thẻ và phân loại

- ✅ Thẻ (tags) để tổ chức ghi chú
- ✅ Phân loại theo danh mục (category)
- ✅ Lọc theo thẻ và danh mục

### 📅 Lên lịch và nhắc nhở

- ✅ Chọn ngày và giờ cho ghi chú
- ✅ Hiển thị ghi chú theo lịch
- ✅ Nhận diện ghi chú quá hạn
- ✅ Cài đặt loại nhắc nhở

### 🔍 Tìm kiếm và lọc

- ✅ Tìm kiếm theo từ khóa trong tiêu đề, nội dung, thẻ
- ✅ Lọc theo danh mục, thẻ, mức ưu tiên
- ✅ Lọc theo trạng thái (yêu thích, hoàn thành)
- ✅ Sắp xếp theo ngày, tiêu đề, mức ưu tiên

### 📊 Giao diện hiển thị

- ✅ Hiển thị dạng lưới (grid view)
- ✅ Hiển thị lịch (calendar view)
- ✅ Hiển thị ghi chú hoàn thành
- ✅ Thống kê tổng quan

### 🎨 Tính năng nâng cao

- ✅ Mức ưu tiên (Thấp, Trung bình, Cao)
- ✅ Giao diện Material Design 3
- ✅ Responsive design
- ✅ Animation mượt mà

## 🗃️ Cấu trúc cơ sở dữ liệu

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  category TEXT,
  tags TEXT,
  isFavorite INTEGER NOT NULL DEFAULT 0,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  scheduledDate INTEGER,
  priority INTEGER NOT NULL DEFAULT 2,
  reminderType TEXT
)
```

## 📁 Cấu trúc dự án

```
lib/
├── models/
│   └── note.dart                    # Model dữ liệu Note với đầy đủ thuộc tính
├── database/
│   └── database_helper.dart         # Helper quản lý SQLite với FFI support
├── providers/
│   └── notes_provider.dart          # Provider quản lý state với filter nâng cao
├── screens/
│   ├── home_screen_enhanced.dart    # Màn hình chính với statistics
│   ├── calendar_screen.dart         # Màn hình hiển thị lịch
│   └── add_edit_note_screen.dart    # Màn hình thêm/sửa note
├── widgets/
│   ├── note_card_enhanced.dart      # Widget hiển thị note card với đầy đủ info
│   ├── search_bar_widget.dart       # Widget thanh tìm kiếm
│   ├── category_chips.dart          # Widget chip danh mục
│   ├── tag_input_widget.dart        # Widget nhập thẻ
│   ├── priority_selector.dart       # Widget chọn mức ưu tiên
│   └── filter_bottom_sheet.dart     # Widget bottom sheet filter
├── utils/
│   ├── app_theme.dart               # Cấu hình theme
│   └── constants.dart               # Hằng số ứng dụng
└── main.dart                        # Entry point
```

## 📦 Dependencies chính

```yaml
dependencies:
  flutter: sdk
  sqflite: ^2.3.0 # SQLite database
  sqflite_common_ffi: ^2.3.0 # FFI support cho desktop
  provider: ^6.1.2 # State management
  flutter_staggered_grid_view: ^0.7.0 # Grid layout linh hoạt
  table_calendar: ^3.0.9 # Calendar widget
  intl: ^0.19.0 # Định dạng ngày tháng
  flutter_local_notifications: ^17.2.2 # Thông báo local
  file_picker: ^8.1.2 # File picker
  csv: ^6.0.0 # Export CSV
```

## 🚀 Cách chạy

1. **Cài đặt Flutter SDK**
2. **Clone project và cài dependencies:**

```bash
git clone <repository_url>
cd note
flutter pub get
```

3. **Chạy ứng dụng:**

```bash
flutter run
```

## 📱 Hướng dẫn sử dụng

### Tạo ghi chú mới

1. Nhấn nút **+** trên màn hình chính
2. Nhập tiêu đề, nội dung
3. Chọn danh mục và thẻ
4. Thiết lập mức ưu tiên
5. Chọn ngày giờ nếu cần lên lịch
6. Nhấn **Save**

### Tìm kiếm và lọc

1. Sử dụng thanh tìm kiếm ở đầu màn hình
2. Nhấn icon **Filter** để mở bộ lọc nâng cao
3. Chọn danh mục từ chip list
4. Toggle yêu thích/hoàn thành từ app bar

### Xem theo lịch

1. Nhấn icon **View mode** trên app bar
2. Chọn **Calendar View**
3. Nhấn vào ngày để xem ghi chú của ngày đó

### Quản lý trạng thái

- **Yêu thích**: Nhấn icon ❤️ trên note card
- **Hoàn thành**: Nhấn icon ✅ trên note card
- **Xóa**: Nhấn icon 🗑️ trên note card

## 🎯 Tính năng sắp tới

- [ ] Thông báo push notification
- [ ] Đồng bộ với Google Calendar
- [ ] Export/Import dữ liệu
- [ ] Dark/Light theme toggle
- [ ] Backup & restore
- [ ] Chia sẻ ghi chú
- [ ] Markdown support
- [ ] Voice notes
- [ ] Attach files/images

## 🛠️ Kiến trúc kỹ thuật

### State Management

- **Provider pattern** cho quản lý state toàn app
- **ChangeNotifier** cho reactive updates
- **Consumer/Selector** cho optimized rebuilds

### Database

- **SQLite** với `sqflite` package
- **FFI support** cho desktop platforms
- **Migration support** cho schema updates
- **Optimized queries** với indexing

### UI/UX

- **Material Design 3** guidelines
- **Responsive design** cho multi-platform
- **Staggered grid** cho flexible layout
- **Bottom sheets** cho filters và actions

### Performance

- **Lazy loading** cho large datasets
- **Debounced search** để tránh spam queries
- **Optimized rebuilds** với Consumer pattern
- **Memory efficient** widgets

## 📄 License

MIT License - xem file LICENSE để biết thêm chi tiết.

## 👨‍💻 Tác giả

Được phát triển bằng Flutter với ❤️

---

**Note**: Đây là ứng dụng demo showcasing các best practices trong Flutter development với SQLite integration.

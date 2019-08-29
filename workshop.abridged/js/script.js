/*val() v.s .value 
  validation
  html冒泡 preventDefault()
  dataSource.read()  data()
  為功能還有不熟悉的function作註解*/
var bookDataFromLocalStorage = [];
$(function () {
  loadBookData();
  var data = [                                         // 這樣存資料不好
    { text: "資料庫", value: "image/database.jpg" },
    { text: "網際網路", value: "image/internet.jpg" },
    { text: "應用系統整合", value: "image/system.jpg" },
    { text: "家庭保健", value: "image/home.jpg" },
    { text: "語言", value: "image/language.jpg" }
  ];
  $("#book_category").kendoDropDownList({
    dataTextField: "text",
    dataValueField: "value",
    dataSource: data,
    index: 0,
    change: onChangeBookCategory
  });

  $("#bought_datepicker").kendoDatePicker();   //在畫面中碰到這個欄位會出現DatePicker小對話方框-->不太好
  $(".add-book-window").kendoWindow({
    width: "600px",
    visible: false,
    actions: ["Pin", "Minimize", "Maximize", "Close"],
    close: onCloseWindow                        //函式取onClose不好 如果下次有其他物件要做onClose會混淆
  });
  $("#book_grid").kendoGrid({
    dataSource: {
      data: bookDataFromLocalStorage,
      schema: {
        model: {
          fields: {
            BookId: { type: "int" },
            BookName: { type: "string" },
            BookCategory: { type: "string" },
            BookAuthor: { type: "string" },
            BookBoughtDate: { type: "string" }
          }
        }
      },
      filter: {},
      pageSize: 20
    },
    toolbar: kendo.template(
      "<div class='book-grid-toolbar'><input class='book-grid-search' placeholder='我想要找......' type='text'></input></div>"
    ),
    height: 550,
    sortable: true,
    pageable: {
      input: true,
      numeric: false
    },
    columns: [
      { field: "BookId", title: "書籍編號", width: "10%" },
      { field: "BookName", title: "書籍名稱", width: "50%" },
      { field: "BookCategory", title: "書籍種類", width: "10%" },
      { field: "BookAuthor", title: "作者", width: "15%" },
      { field: "BookBoughtDate", title: "購買日期", width: "15%" },
      {
        command: { text: "刪除", click: deleteBook },
        title: " ",
        width: "120px"
      }
    ]
  });
  $(".book-grid-search").on("input", searchBook);
});

function searchBook() {
  var value = this.value;
  var filters = { field: "BookName", operator: "contains", value: value };
  $("#book_grid").data("kendoGrid").dataSource.filter(filters);
}

function loadBookData() {
  if (localStorage.getItem("bookData")) {
    bookDataFromLocalStorage = JSON.parse(localStorage.getItem("bookData"));
  } else {
    bookDataFromLocalStorage = bookData;
    localStorage.setItem("bookData", JSON.stringify(bookDataFromLocalStorage));
  }
}

function onChangeBookCategory() {
  var categoryImg = $("#book_category").val();
  $(".book-image").attr("src", categoryImg);
}
function openAddBookWindow() {
  $(".add-book-window").data("kendoWindow").center().open();
  $("open_window_btn").fadeOut();
}

function onCloseWindow() {
  clearInput();
  $("open_window_btn").fadeIn();
}
function add_Book() {
  var boughtDate = new Date($("#bought_datepicker").val());    //可以用kendo的getvalue方法 undefined的資料會回傳null
  var dd = String(boughtDate.getDate()).padStart(2, '0');      //kendo.toString(new Date(),"yyyy-MM-dd")就可以簡單的轉換格式
  var mm = String(boughtDate.getMonth() + 1).padStart(2, '0');
  var yyyy = boughtDate.getFullYear();
  boughtDate = yyyy + '-' + mm + '-' + dd;
  bookDataFromLocalStorage = JSON.parse(localStorage.getItem("bookData"));
  var new_bookId =
    parseInt(
      bookDataFromLocalStorage[bookDataFromLocalStorage.length - 1].BookId
    ) + 1;
  var new_book = bookDataFormat;    //注意Json的格式:一組資料是用大括號括起來{}
  new_book.BookId = new_bookId;
  new_book.BookCategory = $("#book_category").data("kendoDropDownList").text();
  new_book.BookName = $("#book_name").val();
  new_book.BookAuthor = $("#book_author").val();
  new_book.BookBoughtDate = boughtDate.toString();
  new_book.BookPublisher = $("#book_publisher").val();
  bookDataFromLocalStorage.push(new_book);
  $("#book_grid").data("kendoGrid").dataSource.data(bookDataFromLocalStorage);
  localStorage.setItem("bookData", JSON.stringify(bookDataFromLocalStorage));
  $(".add-book-window").data("kendoWindow").close();
  clearInput();
}
function clearInput() {
  $("#book_name").val("");
  $("#book_author").val("");
  $("#book_publisher").val("");
}
function deleteBook(e) {
  e.preventDefault();
  var tr = $(e.target).closest("tr");
  var rowdata = this.dataItem(tr);
  var index = bookDataFromLocalStorage.findIndex(compare, rowdata.BookId);
  bookDataFromLocalStorage.splice(index, 1);
  localStorage.setItem("bookData", JSON.stringify(bookDataFromLocalStorage));
  $("#book_grid").data("kendoGrid").dataSource.data(bookDataFromLocalStorage);
}
function compare(data) {
  return data.BookId == this.toString();
}

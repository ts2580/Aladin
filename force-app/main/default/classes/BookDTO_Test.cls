@IsTest
private class BookDTO_Test {
  @IsTest
  static void holdsBookAndBranchValues() {
    BookDTO.BookByVolume book = new BookDTO.BookByVolume();
    book.name = '테스트 도서';
    book.volume = 2;
    BookDTO.BranchBook branchBook = new BookDTO.BranchBook();
    branchBook.name = book.name;
    branchBook.volume = book.volume;

    System.assertEquals('테스트 도서', branchBook.name);
    System.assertEquals(2, branchBook.volume);
  }
}

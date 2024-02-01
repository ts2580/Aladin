/**
 * Created by 한성진 on 2024-01-22.
 */

public with sharing class BookDTO {

    public class BookByVolume {
        public Integer seq;
        public String  book;
        public String  cover;
        public String  isbn13;
        public String  price;
        public Boolean ispurchased;
        public String  name;
        public String  type;
        public Integer volume;
        public Boolean noneedtobuy;
        public Integer id;
        public String  isbn;
        public String  description;
        public String  link;
        public Datetime pubdate;
        public String  author;
    }

    public class Branchbook {
        public String  book;
        public Integer volume;
        public String  name;
        public String  branch;
        public String  branchName;
        public String  bookLink;
        public String  minPrice;
        public Integer id;
    }


}
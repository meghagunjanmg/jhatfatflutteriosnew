class SubCategoryList {
  dynamic subcatId;
  dynamic categoryId;
  dynamic subcatName;
  dynamic subcatImage;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic istabacco;
  dynamic ispres;
  dynamic isid;
  dynamic isbasket;

  SubCategoryList(
      this.subcatId,
      this.categoryId,
      this.subcatName,
      this.subcatImage,
      this.createdAt,
      this.updatedAt,
      this.istabacco,
      this.ispres,
      this.isid,
      this.isbasket);

  SubCategoryList.fromJson(Map<String, dynamic> json) {
  subcatId = json['subcat_id'];
  categoryId = json['category_id'];
  subcatName = json['subcat_name'];
  subcatImage = json['subcat_image'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  istabacco = json['istabacco'];
  ispres = json['ispres'];
  isid = json['isid'];
  isbasket = json['isbasket'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['subcat_id'] = this.subcatId;
  data['category_id'] = this.categoryId;
  data['subcat_name'] = this.subcatName;
  data['subcat_image'] = this.subcatImage;
  data['created_at'] = this.createdAt;
  data['updated_at'] = this.updatedAt;
  data['istabacco'] = this.istabacco;
  data['ispres'] = this.ispres;
  data['isid'] = this.isid;
  data['isbasket'] = this.isbasket;
  return data;
  }
  }
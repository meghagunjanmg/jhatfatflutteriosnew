class subscriptionlist {
  int? planId;
  String? plans;
  String? days;
  String? description;
  String? skipDays;
  int? amount;
  dynamic banner;

  subscriptionlist(
      {this.planId,
        this.plans,
        this.days,
        this.description,
        this.skipDays,
        this.amount,
        this.banner});

  subscriptionlist.fromJson(Map<String, dynamic> json) {
    planId = json['plan_id'];
    plans = json['plans'];
    days = json['days'];
    description = json['description'];
    skipDays = json['skip_days'];
    amount = json['amount'];
    banner = json['banner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan_id'] = this.planId;
    data['plans'] = this.plans;
    data['days'] = this.days;
    data['description'] = this.description;
    data['skip_days'] = this.skipDays;
    data['amount'] = this.amount;
    data['banner'] = this.banner;
    return data;
  }
}


class GetUsersModel {
  int? userId;
  String? userName;
  String? userFullName;
  String? address;
  String? dob;
  String? doa;
  String? gender;
  bool? isAdmin;
  bool? isEnabled;
  String? userEmail;
  String? roleName;
  String? displayName;
  int? firmId;
  String? password;
  String? firmName;
  String? gstin;
  int? userRoleId;
  String? mobile;
  String? customerCode;
  String? lastSavedCustomDashboard;
  bool? isActive;

  GetUsersModel({
    this.userId,
    this.userName,
    this.userFullName,
    this.address,
    this.dob,
    this.doa,
    this.gender,
    this.isAdmin,
    this.isEnabled,
    this.userEmail,
    this.roleName,
    this.displayName,
    this.firmId,
    this.password,
    this.firmName,
    this.gstin,
    this.userRoleId,
    this.mobile,
    this.customerCode,
    this.lastSavedCustomDashboard,
    this.isActive,
  });

  GetUsersModel.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    userName = json['UserName'];
    userFullName = json['UserFullName'];
    address = json['Address'];
    dob = json['DOB'];
    doa = json['DOA'];
    gender = json['Gender'];
    isAdmin = json['IsAdmin'];
    isEnabled = json['IsEnabled'];
    userEmail = json['UserEmail'];
    roleName = json['RoleName'];
    displayName = json['DisplayName'];
    firmId = json['FirmId'];
    password = json['Password'];
    firmName = json['FirmName'];
    gstin = json['GSTIN'];
    userRoleId = json['UserRoleId'];
    mobile = json['Mobile'];
    customerCode = json['CustomerCode'];
    lastSavedCustomDashboard = json['LastSavedCustomDasboard'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['UserId'] = userId;
    data['UserName'] = userName;
    data['UserFullName'] = userFullName;
    data['Address'] = address;
    data['DOB'] = dob;
    data['DOA'] = doa;
    data['Gender'] = gender;
    data['IsAdmin'] = isAdmin;
    data['IsEnabled'] = isEnabled;
    data['UserEmail'] = userEmail;
    data['RoleName'] = roleName;
    data['DisplayName'] = displayName;
    data['FirmId'] = firmId;
    data['Password'] = password;
    data['FirmName'] = firmName;
    data['GSTIN'] = gstin;
    data['UserRoleId'] = userRoleId;
    data['Mobile'] = mobile;
    data['CustomerCode'] = customerCode;
    data['LastSavedCustomDasboard'] = lastSavedCustomDashboard;
    data['IsActive'] = isActive;
    return data;
  }
}
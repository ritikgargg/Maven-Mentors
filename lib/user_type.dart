enum UserType{
  Mentor,
  Mentee,
  Admin,
}

class UserTypeInfo{
  static UserTypeInfo instance= UserTypeInfo();
  UserType userType;
}
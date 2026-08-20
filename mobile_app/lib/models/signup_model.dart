class SignupModel {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String district;

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.district = '',
  });

  bool get passwordsMatch => password == confirmPassword;

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'district': district.trim(),
    };
  }
}

// class DistrictOfficerModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String phoneNumber;

//   DistrictOfficerModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.phoneNumber,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'name': name,
//       'email': email,
//       'phoneNumber': phoneNumber,
//     };
//   }

//   factory DistrictOfficerModel.fromMap(Map<String, dynamic> map) {
//     return DistrictOfficerModel(
//       uid: map['uid'] ?? '',
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       phoneNumber: map['phoneNumber'] ?? '',
//     );
//   }
//}
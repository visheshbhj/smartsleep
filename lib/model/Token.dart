class Token {
  String accessToken;
  int expiresIn;
  String refreshToken;
  String tokenType;
  String userId;

  Token(
      {this.accessToken,
        this.expiresIn,
        this.refreshToken,
        this.tokenType,
        this.userId});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    refreshToken = json['refresh_token'];
    tokenType = json['token_type'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['refresh_token'] = this.refreshToken;
    data['token_type'] = this.tokenType;
    data['user_id'] = this.userId;
    return data;
  }

  void setter(Token src){
    this.accessToken = src.accessToken;
    this.expiresIn = src.expiresIn;
    this.refreshToken = src.refreshToken;
    this.tokenType = src.tokenType;
    this.userId = src.userId;
  }

}

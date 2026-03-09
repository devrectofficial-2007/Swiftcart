class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swiftcart Admin Panel")),
      body: Center(child: Text("Welcome, Admin! (Add Products Here)")),
    );
  }
}

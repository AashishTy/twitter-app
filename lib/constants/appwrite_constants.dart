class AppwriteConstants {
  static const String databaseId = '642d918e6cd0cdc0884a';
  static const String projectId = '642d8a566b6b2656ed8e';
  static const String endPoint = 'http://192.168.0.102:8027/v1';

  static const String usersCollection = '6439803d0df80c6e0e5c';
  static const String tweetsCollection = '643b02dd875c463e5b23';

  static const String imagesBucket = '643b12a703bdcfaf704d';

  static String imageUrl(String imageId) => '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';

  static String latestTweetChannel()
    => 'databases.$databaseId.collections.$tweetsCollection.documents';

  static String latestUserChannel()
    => 'databases.$databaseId.collections.$usersCollection.documents';
}
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://appabsensi.mobileprojp.com/api")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/register")
  Future<dynamic> register(@Body() Map<String, dynamic> body);

  @POST("/login")
  Future<dynamic> login(@Body() Map<String, dynamic> body);

  @GET("/profile")
  Future<dynamic> getProfile();

  @PUT("/profile")
  Future<dynamic> editProfile(@Body() Map<String, dynamic> body);

  @PUT("/profile/photo")
  Future<dynamic> editProfilePhoto(@Body() Map<String, dynamic> body);

  @GET("/trainings")
  Future<dynamic> getTrainings();

  @GET("/trainings/{id}")
  Future<dynamic> getTrainingDetail(@Path("id") int id);

  @GET("/users")
  Future<dynamic> getUsers({
    @Query("page") int? page,
    @Query("limit") int? limit,
  });

  @GET("/batches")
  Future<dynamic> getBatches();

  @POST("/absen/check-in")
  Future<dynamic> checkIn(@Body() Map<String, dynamic> body);

  @POST("/absen/check-out")
  Future<dynamic> checkOut(@Body() Map<String, dynamic> body);

  @GET("/absen/history")
  Future<dynamic> getHistoryAbsen();

  @DELETE("/absen/{id}")
  Future<dynamic> deleteAbsen(@Path("id") int id);
}

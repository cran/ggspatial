
test_that("df_spatial() works with sp objects", {
  skip_if_not_installed("sp")

  # load the long lake test data
  load_longlake_data(vector_format = "sp")

  # point / sp
  df_points <- expect_df_spatial(longlake_depthdf, c("NOTES", "DEPTH_M"))
  expect_true(inherits(df_points$part_id, "integer"))
  expect_equal(nrow(df_points), nrow(longlake_depthdf))

  df_points_sfc <- expect_df_spatial(as(longlake_depthdf, "SpatialPoints"))
  expect_identical(df_points_sfc, df_points[c("x", "y", "feature_id", "part_id")])

  # linestring
  df_lines <- expect_df_spatial(longlake_roadsdf, "OBJECTID")
  expect_true(inherits(df_lines$part_id, "integer"))
  expect_setequal(df_lines$feature_id, seq_len(nrow(longlake_roadsdf)))

  df_lines_sfc <- expect_df_spatial(as(longlake_roadsdf, "SpatialLines"))
  expect_identical(df_lines_sfc, df_lines[c("x", "y", "feature_id", "part_id")])

  # polygon
  df_polygons <- expect_df_spatial(longlake_waterdf, c("part_id", "piece_id"))
  expect_true(inherits(df_polygons$part_id, "integer"))
  expect_true(inherits(df_polygons$piece_id, "integer"))
  expect_length(unique(df_polygons$feature_id), nrow(longlake_waterdf))
  expect_length(unique(df_polygons$part_id), 1)
  expect_length(unique(df_polygons$piece_id), 7)

  df_polygons_sfc <- expect_df_spatial(
    as(longlake_waterdf, "SpatialPolygons"),
    c("part_id", "piece_id")
  )
  expect_identical(
    df_polygons_sfc,
    df_polygons[c("x", "y", "feature_id", "part_id", "piece_id")]
  )
})

test_that("df_spatial() works with sp objects where column names are duplicated", {
  skip_if_not_installed("sp")

  spdf <- sp::SpatialPointsDataFrame(
    expand.grid(x = c(30, 60), y = c(40, 70)), data = data.frame(feat_name = 1:4)
  )

  expect_identical(
    df_spatial(spdf),
    tibble::tibble(
      !!!expand.grid(x = c(30, 60), y = c(40, 70)),
      feature_id = 1:4,
      part_id = 1L,
      feat_name = 1:4
    )
  )
})

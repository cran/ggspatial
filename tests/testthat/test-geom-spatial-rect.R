
test_that("geom_spatial_rect() works", {
  # Canada!
  tile_df <- expand.grid(
    xmin = seq(-140, -52, by = 20),
    ymin = seq(40, 70, by = 10)
  )

  tile_df$xmax <- tile_df$xmin + 20
  tile_df$ymax <- tile_df$ymin + 10
  tile_df$x <- (tile_df$xmin + tile_df$xmax) / 2
  tile_df$y <- (tile_df$ymin + tile_df$ymax) / 2
  tile_df$width <- 20
  tile_df$height <- 10


  p <- ggplot(
    tile_df,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, x = x, y = y)
  ) +
    # use something with WGS84 ellipsoid so there's no datum transform
    # this is EPSG:3979 with WGS84 ellipsoid
    coord_sf(
      crs = "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=49 +lon_0=-95 +x_0=0 +y_0=0 +type=crs"
    )

  expect_message(
    ggplot2::ggplot_build(p + geom_spatial_rect()),
    "Assuming `crs = 4326`"
  )

  expect_silent(
    ggplot2::ggplot_build(p + geom_spatial_rect(crs = 4326))
  )

  skip_if_not_installed("vdiffr")

  expect_doppelganger(
    "geom_spatial_rect()",
    p + geom_spatial_rect(crs = 4326)
  )

  expect_doppelganger(
    "geom_spatial_rect(), mapped aes",
    p + geom_spatial_rect(aes(fill = factor(xmin)), crs = 4326)
  )

  expect_doppelganger(
    "geom_spatial_tile(), mapped dims",
    p + geom_spatial_tile(aes(height = 7.5, width = 5), crs = 4326)
  )

  expect_doppelganger(
    "geom_spatial_tile(), auto dims",
    p + geom_spatial_tile(crs = 4326)
  )
})

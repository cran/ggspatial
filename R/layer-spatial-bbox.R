
#' Add a bounding box to a map
#'
#' To include a bounding box without drawing it, use [shadow_spatial()] on the
#' original object.
#'
#' @param data A bounding box generated by [sf::st_bbox()]
#' @param detail Passed to [sf::st_segmentize()]: the number of line segments
#'   per quadrant of the bounding box. Increase this number for a smoother
#'   projected bounding box.
#' @inheritParams layer_spatial
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' load_longlake_data(which = c("longlake_waterdf", "longlake_depthdf"))
#' ggplot() +
#'   layer_spatial(sf::st_bbox(longlake_waterdf)) +
#'   layer_spatial(longlake_depthdf)
#'
#' # use shadow_spatial() to include the geographic area of an object
#' # without drawing it
#' ggplot() +
#'   shadow_spatial(longlake_waterdf) +
#'   layer_spatial(longlake_depthdf)
#' }
#'
layer_spatial.bbox <- function(data, mapping = aes(), ..., detail = 30) {
  layer_spatial(sf_bbox_to_sf(data, detail = detail), mapping = mapping, ...)
}

#' @rdname layer_spatial.bbox
#' @export
annotation_spatial.bbox <- function(data, mapping = aes(), ..., detail = 30) {
  annotation_spatial(sf_bbox_to_sf(data, detail = detail), mapping = mapping, ...)
}

#' @rdname layer_spatial.bbox
#' @export
shadow_spatial.bbox <- function(data, ..., detail = 30) {
  shadow_spatial(sf_bbox_to_sf(data, detail = detail))
}

sf_bbox_to_sf <- function(data, detail = NULL) {
  xs <- data[c("xmin", "xmin", "xmax", "xmax", "xmin")]
  ys <- data[c("ymin", "ymax", "ymax", "ymin", "ymin")]
  poly <- sf::st_polygon(list(cbind(xs, ys)))

  height <- data["ymax"] - data["ymin"]
  width <- data["xmax"] - data["xmin"]
  if (!is.null(detail) && any(c(height, width) > 0)) {
    dfMaxLength <- min(
      c(
        height[height > 0] / detail,
        width[width > 0] / detail
      )
    )
    poly <- sf::st_segmentize(poly, dfMaxLength = dfMaxLength)
  }

  geometry <- sf::st_sfc(poly, crs = sf::st_crs(data))
  tbl <- tibble::tibble(geometry = geometry)
  sf::st_sf(tbl)
}

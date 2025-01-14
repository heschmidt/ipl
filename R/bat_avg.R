#' Calculate batting average of batsmen by season
#'
#'
#' @param players a list of batsmen for whom batting average has to be calculated,
#' as character vectors
#' @param years a list of seasons (years) for which the batting average of the
#' given batsmen has to be calculated, as numeric vectors
#'
#' @return `bat_avg` returns a data frame with `nrow` equal to the product of the
#' number of players and years inputted and 5 columns.
#'
#' @examples
#'
#' library(ipl)
#'
#' # Compute batting average of Virat Kohli in 2019
#' bat_avg("V Kohli", 2019)
#'
#'
#' # Compute batting averages of Virat Kohli, MS Dhoni, Rohit Sharma in
#' # 2017, 2018, and 2019
#' bat_avg(c("V Kohli", "MS Dhoni", "RG Sharma"), c(2017, 2018, 2019))
#' @importFrom magrittr "%>%"
#' @import dplyr
#' @export

bat_avg <- function(players, years) {
  avg_calc <- function(player, yr) {
    deliveries %>%
      filter(
        batsman %in% player,
        year %in% yr
      ) %>%
      group_by(batsman, year) %>%
      summarise(
        player_runs = sum(batsman_runs),
        player_wickets = length(unique(.$id[.$is_wicket == 1])),
        batting_avg = round(player_runs / player_wickets, 2)
      ) %>%
      ungroup()
  }

  avgs <- data.frame(
    batsman = NA,
    year = NA,
    player_runs = NaN,
    player_wickets = NaN,
    batting_avg = NaN
  )


  for (pl in players) {
    for (y in years) {
      if (!is.character(pl)) {
        stop("Invalid input: player should be a character vector", call. = FALSE)
      } else if (!is.numeric(y)) {
        stop("Invalid input: year should be a numeric vector", call. = FALSE)
      } else if (!(pl %in% deliveries$batsman)) {
        stop(paste0(pl, " not found! \n"), call. = FALSE)
      } else if (!(y %in% deliveries$year)) {
        stop(paste0(y, " year not found! \n"), call. = FALSE)
      } else {
        avgs <- full_join(avgs, avg_calc(pl, y),
          by = c(
            "batsman", "year", "player_runs",
            "player_wickets", "batting_avg"
          )
        )
      }
    }
  }

  avgs <- avgs %>%
    filter(!is.na(batsman))

  return(avgs)
}

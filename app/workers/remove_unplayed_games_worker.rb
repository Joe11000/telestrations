class RemoveUnplayedGamesWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(30) }

  def perform(*args)
    # optimize this in SQL at a later date
    logger.info "Running Game Clean Up"
    unused_games = Game.ids - GamesUser.pluck(:game_id).uniq
    games_deleting = Game.where('games.id IN (:id) and games.updated_at < :time ', { id: unused_games, time: 20.minutes.ago.iso8601 })

    logger.info "Deleting Games #{games_deleting.ids.sort.inspect}"
    games_deleting.destroy_all

    logger.info "Running Game Clean Up"

    # Project.joins( :vacancies ).group( 'projects.id' ).having( 'count( project_id ) > 1' )
    # Game.joins( :games_users ).group( 'game.id' ).having( 'count( game_id ) = 0' )
  end
end

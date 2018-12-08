import React from 'react'
import PropTypes from 'prop-types'
import GameSelector from '../GameSelector'
import SlideshowList from '../SlideshowList'

export default class PostGameTab extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return(
      <div>
        { !!this.props.all_postgames_of__current_user &&
          !!this.props.current_postgame_id &&
          <div>
            <h3 className='card-title'>Post Game Results</h3>
            <GameSelector all_postgames_of__current_user={this.props.all_postgames_of__current_user}
                          retrieveCardsForPostgame={this.props.retrieveCardsForPostgame }
                          current_postgame_id={this.props.current_postgame_id}
                          />

            <SlideshowList arr_of_postgame_card_set={this.props.arr_of_postgame_card_set} />
          </div>
        }
      </div>
    )
  }
}

PostGameTab.propTypes = {
  selectTab: PropTypes.func.isRequired,
  retrieveCardsForPostgame: PropTypes.func.isRequired,
    // all_postgames_of__current_user: PropTypes.shape({
  //                                   id: PropTypes.number.isRequired,
  //                                   created_at_strftime: PropTypes.string.isRequired
  //                                 })
  current_postgame_id: PropTypes.number
}

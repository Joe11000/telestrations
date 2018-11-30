import React from 'react'
import PropTypes from 'prop-types'
import GameSelector from '../GameSelector'
import SlideshowList from '../SlideshowList'

export default class PostGameTab extends React.Component {
  constructor(props){
    super(props);
    // debugger
  }

  componentDidMount(){
    // Controller knows game_id of -1 means like accessing user's last postgame(like in an array[-1])
    this.props.retrieveCardsForPostgame(-1);
  }

  render() {
    debugger
    return(
      <div>
        { !!this.props.all_postgames_of__current_user &&
          <div>
            <h3 className='card-title'>Post Game Results</h3>
            <GameSelector all_postgames_of__current_user={this.props.all_postgames_of__current_user}
                          retrieveCardsForPostgame={this.props.retrieveCardsForPostgame }
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
  all_postgames_of__current_user: PropTypes.shape({
                                    id: PropTypes.number.isRequired,
                                    created_at_strftime: PropTypes.string.isRequired
                                  })
}

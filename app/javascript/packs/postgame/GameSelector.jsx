import React from 'react'
import PropTypes from 'prop-types'

export default class GameSelector extends React.Component {
  constructor(props){
    super(props);
    debugger

    this.handleChangeGameSelector = this.handleChangeGameSelector.bind(this);
  }

  handleChangeGameSelector(event){
    event.preventDefault();
    let game_id = parseInt(event.target.value)
    debugger
    this.props.retrieveCardsForPostgame(game_id)
  }

  render() {
    debugger
    return (
      <div id='game-selector-container'>
        { !!this.props.all_postgames_of__current_user &&
          <select className='custom-select' onChange={this.handleChangeGameSelector}>
            {
              this.props.all_postgames_of__current_user.map(function(game_info, index) {
                return(<option key={game_info.id} value={game_info.id}>Game {index + 1} - {game_info.created_at_strftime}</option>);
              })
            }
          </select>
        }
      </div>
    );
  }
}

GameSelector.propTypes = {
  all_postgames_of__current_user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    created_at_strftime: PropTypes.string.isRequired
  }),
  retrieveCardsForPostgame: PropTypes.func.isRequired
}

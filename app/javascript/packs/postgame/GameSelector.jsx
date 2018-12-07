import React from 'react'
import PropTypes from 'prop-types'

export default class GameSelector extends React.Component {
  handleChangeGameSelector = event => {
    event.preventDefault();
    let game_id = parseInt(event.target.value)
    this.props.retrieveCardsForPostgame(game_id)
  }

  render() {
    var that = this;
    debugger
    return (
      <div id='game-selector-container'>
        {
          !!this.props.all_postgames_of__current_user &&
          <select value={this.props.current_postgame_id} className='custom-select' onChange={this.handleChangeGameSelector}>
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
  all_postgames_of__current_user: PropTypes.arrayOf(function(propValue, key, componentName, location, propFullName) {
    let _propValueTypesValidator = {
      'id': 'number',
      'created_at_strftime': 'string'
    }

    Object.keys(_propValueTypesValidator).forEach(propValueKey => {
      if(typeof propValue[key][propValueKey] != _propValueTypesValidator[propValueKey]) {
        return new Error(
          'Invalid prop `' + propFullName + '` supplied to' +
          ' `' + componentName + '`. Validation failed.'
        )
      }
    })
  }).isRequired,

  current_postgame_id: PropTypes.number.isRequired,
  retrieveCardsForPostgame: PropTypes.func.isRequired,
}

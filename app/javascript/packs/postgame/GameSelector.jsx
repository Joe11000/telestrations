import React from 'react';
import PropTypes from 'prop-types';

export default class GameSelector extends React.Component {
  constructor(props){
    super(props);
  }
  handleChangeGameSelector = event => {
    event.preventDefault();
    const game_id = parseInt(event.target.value);
    this.props.retrieveCardsForPostgame(game_id);
  }

  render() {
    const {all_postgames_of__current_user, current_postgame_id} = this.props;
    
    
    // debugger
    return (
      <React.Fragment>
        {
          all_postgames_of__current_user &&
          current_postgame_id &&
          <select value={current_postgame_id} className='custom-select' onChange={this.handleChangeGameSelector}>
            {
              all_postgames_of__current_user.map(function(game_info, index) {
                return(<option key={game_info.id} value={game_info.id}>Game {index + 1} - {game_info.created_at_strftime}</option>);
              })
            }
          </select>
        }
      </React.Fragment>
    )
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

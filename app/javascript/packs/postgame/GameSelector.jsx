import React from 'react'
import PropTypes from 'prop-types'

export default class GameSelector extends React.Component {
  constructor(props){
    super(props);
    debugger
  }

  render() {
    return (
      <div>
        { !!this.props.list_of_game_ids &&
          <select className='custom-select'>
            { this.props.list_of_game_ids.map(function(game_id, index) {
              return(<option value={game_id}>Game {index + 1}</option>)
              }
            }
          </select>
        }
      </div>
    )
  }
}

GameSelector.propTypes = {

}

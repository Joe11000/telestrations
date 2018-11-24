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
        { !!this.props.all__current_user__game_info &&
          <select className='custom-select' onChange={this.props.handleGameSelectorChange}>
            {
              this.props.all__current_user__game_info.map(function(game_id, index) {
                return(<option value={game_id}>Game {index + 1}</option>)
              })
            }
          </select>
        }
      </div>
    )
  }
}

GameSelector.propTypes = {

}

import React from 'react'
import PropTypes from 'prop-types'
import GameSelector from '../GameSelector'
import SlideshowList from '../SlideshowList'
import Slideshow from '../Slideshow'
import $ from 'jquery'
import { CardTitle } from 'reactstrap'

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
            <CardTitle>Post Game Results</CardTitle>
            <GameSelector all_postgames_of__current_user={this.props.all_postgames_of__current_user}
                          current_postgame_id={this.props.current_postgame_id}
                          retrieveCardsForPostgame={this.props.retrieveCardsForPostgame }
                          />
            <div className='mt-4 mb-4'></div>
            <SlideshowList arr_of_postgame_card_set={this.props.arr_of_postgame_card_set}
                           current_user_info={this.props.current_user_info}
                            />
          </div>
        }
      </div>
    )
  }
}

PostGameTab.propTypes = {
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
  }),

  current_postgame_id: PropTypes.number,
  retrieveCardsForPostgame: PropTypes.func.isRequired,
  selectTab: PropTypes.func.isRequired,
}

import React from 'react';
import PropTypes from 'prop-types';
import GameSelector from '../GameSelector';
import SlideshowList from '../SlideshowList';
import { CardTitle } from 'reactstrap';

export default class PostGameTab extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    debugger
    const { 
            all_postgames_of__current_user, 
            current_user_info,
            current_postgame_id, 
            retrieveCardsForPostgame, 
          } = this.props;

    const arr_of_decks_of_cards = this.props.arr_of_postgame_card_set;
    return(


      <React.Fragment>
        { !!all_postgames_of__current_user &&
          !!current_postgame_id &&
          <React.Fragment>
            <CardTitle>Post Game Results</CardTitle>
            <GameSelector all_postgames_of__current_user={all_postgames_of__current_user}
                          current_postgame_id={current_postgame_id}
                          retrieveCardsForPostgame={retrieveCardsForPostgame }
                          />
            <div className='mt-4 mb-4'></div>
            <p className='small glow' style={{textAlign: 'right'}}>( * cards with red text were made by you * )</p>
            <SlideshowList arr_of_decks_of_cards={arr_of_decks_of_cards}
                           current_user_info={current_user_info}
                            />
          </React.Fragment>
        }
      </React.Fragment>
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

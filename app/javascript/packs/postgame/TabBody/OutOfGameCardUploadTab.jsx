import React from 'react';
import PropTypes from 'prop-types';
import SlideshowList from '../SlideshowList';
import { CardTitle } from 'reactstrap';

export default class OutOfGameCardUploadTab extends React.Component {
  componentDidMount(){
    debugger
    if(this.props.out_of_game_cards.length == 0){
      this.props.retrieveOutOfGameCards();
    }
  }

  render(){
    const { current_user_info, out_of_game_cards } = this.props;
    debugger
    return(
      <React.Fragment>
      { 
        out_of_game_cards.length == 0 ? 
          <h2>You don't have any images uploaded out of game</h2> : 

          <React.Fragment>
            <CardTitle>Your Drawings not associated to a game</CardTitle>
      
            <div className='mt-4 mb-4'></div> 
            <SlideshowList  arr_of_decks_of_cards={ out_of_game_cards }
                            current_user_info={current_user_info}
                            />
          </React.Fragment>
      }
      </React.Fragment>
    );
  }
}


OutOfGameCardUploadTab.propTypes = {
  current_user_info: PropTypes.shape({
    id: PropTypes.number, 
    name: PropTypes.string,
  }).isRequired,

  out_of_game_cards: PropTypes.arrayOf(
                        PropTypes.shape({
                          id: PropTypes.number, 
                          created_at_strftime: PropTypes.string,
                        }).isRequired).isRequired, 
  retrieveOutOfGameCards: PropTypes.func
}
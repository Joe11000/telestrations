import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import axios from 'axios';


import { Card, CardHeader, CardTitle, CardBody } from 'reactstrap';
import { Nav, NavItem, NavLink } from 'reactstrap';

import OutOfGameCardUploadTab from './TabBody/OutOfGameCardUploadTab';;
import PostGameTab from './TabBody/PostGameTab';
import { request } from 'http';

class Postgame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      'current_user_info': null,
      'tab_selected': undefined, // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab'),
      
      'PostGameTab': {
                      'all_postgames_of__current_user': null,
                      'current_postgame_id': null,
                      'storage_of_viewed_postgames': {}
                    },
      'OutOfGameCardUploadTab': {
                                  'out_of_game_cards': []
                                }
                 };
    
    this.retrieveCardsForPostgame = this.retrieveCardsForPostgame.bind(this);
    this.retrieveOutOfGameCards = this.retrieveOutOfGameCards.bind(this);
  }

  render() {
    let nav_link__postgametab__classes = 'border-white bg-transparent text-white' + (this.state.tab_selected == 'PostGameTab' ? ' active' : '');
    let nav_link__outofgametab__classes = 'border-white text-white' + (this.state.tab_selected == 'OutOfGameCardUploadTab'  ? ' active' : '');

    const { current_user_info } = this.state;

    let card_body_html;
    switch(this.state.tab_selected) {
      case 'PostGameTab':
      case undefined:
        card_body_html = <PostGameTab {...this.statePostGameTab}
                                      retrieveCardsForPostgame={this.retrieveCardsForPostgame}
                                      selectTab={this.selectTab}
                                      />
        break;

      case 'OutOfGameCardUploadTab':
      const { OutOfGameCardUploadTab: out_of_game_cards } =  this.state;
        card_body_html = <OutOfGameCardUploadTab current_user_info={current_user_info} retrieveOutOfGameCards={this.retrieveOutOfGameCards} {...out_of_game_cards} />
        break;
    }

    return (
      <div data-id='postgame-component'>
        <div className='row'>
          <div className='col-12 col-sm-10 offset-sm-1 col-md-8 offset-md-2 col-lg-6 offset-lg-3'>
            <Card className='text-center bg-dark border-primary'>
              <CardHeader>
                <Nav vertical={false} tabs className='card-header-tabs'>
                  <NavItem>
                    <NavLink className={nav_link__postgametab__classes}  
                            onClick={this.selectTab.bind(this, "PostGameTab")} 
                            href='#' >
                      Post Games
                    </NavLink>
                  </NavItem>
                  <NavItem>
                    <NavLink className={nav_link__outofgametab__classes} 
                            onClick={this.selectTab.bind(this, "OutOfGameCardUploadTab")} 
                            href='#'>
                      Out of game card uploads
                    </NavLink>
                  </NavItem>
                </Nav>
              </CardHeader>

              <CardBody>
                {card_body_html}
              </CardBody>
            </Card>
          </div>
        </div>
      </div>
    )
  }

  componentDidMount() {
    debugger;

    // Controller knows game_id of -1 means like accessing user's last postgame(like in an array[-1])
    this.retrieveCardsForPostgame(-1);
  }


  retrieveCardsForPostgame(id) {
    if(id < 0 || this.state.PostGameTab.storage_of_viewed_postgames[id] == null) {

      axios({method: get, 
             url: `/games/${id}`, 
             responseType: 'json'}).then(function(response){
                // on first load, find what the id of the most recent game played is
                let _current_postgame_id;
                if(id == -1) {
                  _current_postgame_id = response.all_postgames_of__current_user[response.all_postgames_of__current_user.length - 1].id;
                }else{
                  _current_postgame_id = id;
                }

                function moldResponse(response) {
                  const new_entry_in_storage_of_viewed_postgames = { [_current_postgame_id]: response.arr_of_postgame_card_set } 
                  
                  const updated_storage_of_viewed_postgames = Object.assign(this.state.PostGameTab.storage_of_viewed_postgames, new_entry_in_storage_of_viewed_postgames);

                  const responseToMergeWithState = {
                                                      'current_user_info': response.current_user_info,
                                                      'tab_selected': 'PostGameTab', // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab'),
                                                      
                                                      'PostGameTab': {
                                                                      'all_postgames_of__current_user': response.all_postgames_of__current_user,
                                                                      'current_postgame_id': _current_postgame_id,
                                                                      'storage_of_viewed_postgames': updated_storage_of_viewed_postgames
                                                                    },
                                                      'OutOfGameCardUploadTab': {
                                                                                  'out_of_game_cards': response.all_postgames_of__current_user
                                                                                }
                                                    };
                  

                  return responseToMergeWithState
                  // debugger
                  // // get arr_of_postgame_card_set
                  // Object.assign(_response, {storage_of_viewed_postgames:  { [_current_postgame_id]: _response.arr_of_postgame_card_set}}); // rename this prop
                  // delete _response.arr_of_postgame_card_set;
                  
                  // const newPostGameTab = Object.assign(_response, {'current_postgame_id': _current_postgame_id });
                  // const current_user_info = newPostGameTab.current_user_info;
                  // delete newPostGameTab.current_user_info;
          
                  // return { tab_selected: 'PostGameTab', PostGameTab: newPostGameTab, current_user_info };
                }

        const responseToMergeWithState = moldResponse.call(this, response);

        this.setState( (state, props) => { 
          return responseToMergeWithState;
        });
      }.bind(this));
    }
    else {
      
      this.setState( function(state) { 
        return { PostGameTab: { current_postgame_id: id } }
      }.bind(this));
    }
  }

  selectTab(tab_selected) {
    switch(tab_selected)
    {
      case 'PostGameTab':
      case 'OutOfGameCardUploadTab':
             this.setState({ tab_selected: tab_selected });
             break;
      default: throw new Error("Invalidly named tab Selected"); 
    }
  }

  retrieveOutOfGameCards(){
    const { OutOfGameCardUploadTab: {out_of_game_cards: out_of_game_cards } } = this.state;

    if( out_of_game_cards.length == 0 ) {
      axios.get(`/cards/out_of_game_card_uploads`).then(function(response) {
        this.setState((state) => {
         return { 
                  'OutOfGameCardUploadTab': {
                                              'out_of_game_cards': response
                                            }
                }

          return response;
        });
      }.bind(this));
    }
  }

  static getDerivedStateFromError(error) {
    debugger;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const selector = "[data-id='postgame-page-data']"
  const node = document.querySelector(selector);
  const data = JSON.parse(node.getAttribute('data'));

    ReactDOM.render(
      <Postgame data={data}/>,
      document.querySelector(selector)
    )
});

export default Postgame;
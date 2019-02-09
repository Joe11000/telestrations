import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import $ from 'jquery';

import { Card, CardHeader, CardTitle, CardBody } from 'reactstrap';
import { Nav, NavItem, NavLink } from 'reactstrap';

import OutOfGameCardUploadTab from './TabBody/OutOfGameCardUploadTab';;
import PostGameTab from './TabBody/PostGameTab';

class Postgame extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      'tab_selected': undefined, // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab'),
      'current_user_info': null,
      
      'PostGameTab': {
                      'all_postgames_of__current_user': null,
                      'arr_of_postgame_card_set': null,
                      'current_postgame_id': null,
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

    const { all_postgames_of__current_user, 
            arr_of_postgame_card_set, 
            current_postgame_id, 
          } = this.state.PostGameTab;

    const { current_user_info } = this.state;
          
    let card_body_html;
    switch(this.state.tab_selected) {
      case 'PostGameTab':
      case undefined:
        card_body_html = <PostGameTab all_postgames_of__current_user={all_postgames_of__current_user}
                                      arr_of_postgame_card_set={arr_of_postgame_card_set}
                                      current_postgame_id={current_postgame_id}
                                      current_user_info={current_user_info}
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

  // I didn't move this down one level to PostGameTab because will be holding onto the retrieved information between tab changes. 
  componentDidMount() {
    // Controller knows game_id of -1 means like accessing user's last postgame(like in an array[-1])
    this.retrieveCardsForPostgame(-1);
  }

  retrieveCardsForPostgame(id) {
    $.getJSON(`/games/${id}`, function(_response) {
      // on first load, find what the id of the most recent game played is
      let _current_postgame_id;
      if(id == -1) {
       _current_postgame_id = _response.all_postgames_of__current_user[_response.all_postgames_of__current_user.length - 1].id;
      }else{
        _current_postgame_id = id;
      }

      const newPostGameTab = Object.assign(_response, {'current_postgame_id': _current_postgame_id});
      const current_user_info = newPostGameTab.current_user_info;
      delete newPostGameTab.current_user_info
      const responseToMergeWithState = { tab_selected: 'PostGameTab', PostGameTab: newPostGameTab, current_user_info};
      
      this.setState( (state, props) => { 
        return responseToMergeWithState;
      });
    }.bind(this));
  }

  selectTab(tab_selected){
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
      $.getJSON(`/cards/out_of_game_card_uploads`, function(response) {
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

export default Postgame
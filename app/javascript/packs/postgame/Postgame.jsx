import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import $ from 'jquery';
// import axios from 'axios';
import { Card, CardHeader, CardTitle, CardBody } from 'reactstrap';
import { Nav, NavItem, NavLink } from 'reactstrap';

import OutOfGameCardUploadTab from './TabBody/OutOfGameCardUploadTab';;
import PostGameTab from './TabBody/PostGameTab';

class Postgame extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
                   'all_postgames_of__current_user': null,
                   'arr_of_postgame_card_set': null,
                   'current_user_info': null,
                   'current_postgame_id': null,
                   'tab_selected': undefined, // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab'),
                 };

    this.retrieveCardsForPostgame = this.retrieveCardsForPostgame.bind(this);
    // this.selectTab = this.selectTab.bind(this);

    this.ref_OutOfGameCardUploadTab = React.createRef();
    this.ref_PostGameTab = React.createRef();
  }

  componentDidMount() {
    // Controller knows game_id of -1 means like accessing user's last postgame(like in an array[-1])
    this.retrieveCardsForPostgame(-1);
  }

  // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab')
  retrieveCardsForPostgame(id) {
    $.getJSON(`/games/${id}`, function(_response) {
      let _current_postgame_id;
      if(id == -1) {
       _current_postgame_id = _response.all_postgames_of__current_user[_response.all_postgames_of__current_user.length - 1].id;
      }else{
        _current_postgame_id = id;
      }
      let _edited_response = Object.assign(_response, {tab_selected: 'PostGameTab', 'current_postgame_id': _current_postgame_id} );
      this.setState(_edited_response);
    }.bind(this));
  }



  selectTab(tab_selected){
    debugger
    switch(this.state.tab_selected)
    {
      case 'PostGameTab':
      case 'OutOfGameCardUploadTab':
             this.setState({ tab_selected: tab_selected });
             break;
      default: throw new Error("Invalidly named tab Selected"); 
    }
  }

  render() {
    let nav_link__postgametab__classes = 'border-white bg-transparent text-white' + (this.state.tab_selected == 'PostGameTab' ? ' active' : '');
    let nav_link__outofgametab__classes = 'border-white text-white' + (this.state.tab_selected == 'OutOfGameCardUploadTab'  ? ' active' : '');

    const { all_postgames_of__current_user, 
            arr_of_postgame_card_set, 
            current_postgame_id, 
            current_user_info, 
          } = this.state;
          
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
        card_body_html = <OutOfGameCardUploadTab current_user_info={current_user_info}/>
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
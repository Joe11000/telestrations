import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import $ from 'jquery'
// import axios from 'axios'
import { Card, CardHeader, CardTitle, CardBody } from 'reactstrap';
import { Nav, NavItem, NavLink } from 'reactstrap';

import OutOfGameCardUploadTab from './TabBody/OutOfGameCardUploadTab'
import PostGameTab from './TabBody/PostGameTab'

class Postgame extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
                   'all_postgames_of__current_user': null,
                   'arr_of_postgame_card_set': null,
                   'current_user_info': null,
                   'current_postgame_id': null,
                   'tab_selected': undefined, // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab')
                 }

    this.retrieveCardsForPostgame = this.retrieveCardsForPostgame.bind(this);
    this.retrieveOutOfGameCards = this.retrieveOutOfGameCards.bind(this);
    this.selectTab = this.selectTab.bind(this);
  }

  componentDidMount() {
    // Controller knows game_id of -1 means like accessing user's last postgame(like in an array[-1])
    this.retrieveCardsForPostgame(-1);
  }

  // tab_selected (undefined||'PostGameTab'||'OutOfGameCardUploadTab')
  retrieveCardsForPostgame(id) {
    var that = this;

    $.getJSON(`/games/${id}`, function(_response) {
      let _current_postgame_id;
      if(id == -1) {
       _current_postgame_id = _response.all_postgames_of__current_user[_response.all_postgames_of__current_user.length - 1].id;
      }else{
        _current_postgame_id = id;
      }
      debugger
      let _edited_response = Object.assign(_response, {tab_selected: 'PostGameTab', 'current_postgame_id': _current_postgame_id} );

      that.setState(_edited_response);
    });
  }

  retrieveOutOfGameCards(){
    var that = this;

    $.getJSON(`/out_of_game_card_uploads_controller/${this.state.current_user_info.id}`, function(response){
      let edited_response = Object.assign(response, {tab_selected: 'OutOfGameCardUploadTab'} );
      that.setState(edited_response);
    });
  }

  selectTab(tab_selected){
    switch(this.state.tab_selected)
    {
      case 'PostGameTab':
      case 'OutOfGameCardUploadTab':
             this.setState({ tab_selected: tab_selected });
             break;
    }
  }

  render() {
    let nav_link__postgametab__classes = 'border-white bg-transparent text-white' + (this.state.tab_selected == 'PostGameTab' ? ' active' : '')
    let nav_link__outofgametab__classes = 'border-white text-white' + (this.state.tab_selected == 'OutOfGameCardUploadTab'  ? ' active' : '')

    let card_body_html;
    switch(this.state.tab_selected) {
      case 'PostGameTab':
      case undefined:
        card_body_html = <PostGameTab all_postgames_of__current_user={this.state.all_postgames_of__current_user}
                                      arr_of_postgame_card_set={this.state.arr_of_postgame_card_set}
                                      current_postgame_id={this.state.current_postgame_id}
                                      current_user_info={this.state.current_user_info}
                                      retrieveCardsForPostgame={this.retrieveCardsForPostgame}
                                      selectTab={this.selectTab}
                                      />;
        break;

      case 'OutOfGameCardUploadTab':
        card_body_html = <OutOfGameCardUploadTab selectTab={this.selectTab} />;
        break;
    }

    return (
      <div data-id='postgame-component'>
        <div className='row'>
          <div className='col-12 col-sm-10 offset-sm-1 col-md-8 offset-sm-2 col-lg-6 offset-lg-3 '>
            <Card className='text-center bg-dark border-primary'>
              <CardHeader>
                <div>

                <Nav vertical={false} tabs className='card-header-tabs'>
                  <NavItem>
                    <NavLink className={nav_link__postgametab__classes}  href='#' >
                      Post Games
                    </NavLink>
                  </NavItem>
                  <NavItem>
                    <NavLink className={nav_link__outofgametab__classes} 
                             onClick={this.retrieveOutOfGameCards} 
                             href='#'>
                      Out of game card uploads
                    </NavLink>
                  </NavItem>
                </Nav>
                </div>
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

    // - unless @out_of_game_card_upload.blank?
    //   h3.h3#out_of_game_card_upload-header.text-center = "Unassociated Cards I've uploaded"
    //   .out_of_game_card_upload-i-uploaded
    //     - carousel_id = "out_of_game_card_upload"
    //     .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
    //       /! Wrapper for slides
    //       .carousel-inner role="listbox"
    //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
    //           .item class=(card_container_index == 0 ? 'active' : '')
    //             = image_tag card_container.drawing.url, alt: 'User Drawing'

    //       /! Controls
    //       a.left.carousel-control data-slide='prev' href="##{carousel_id}" role='button'
    //         i.glyphicon.glyphicon-chevron-left.fa.fa-chevron-left aria-hidden='true'
    //         span.sr-only Previous
    //       a.right.carousel-control data-slide='next' href="##{carousel_id}" role='button'
    //         i.glyphicon.glyphicon-chevron-right.fa.fa-chevron-right aria-hidden='true'
    //         span.sr-only Next
    //       /! Indicators
    //       ol.carousel-indicators
    //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
    //           li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
    //     hr


    // .col-12.col-sm-12.text-center
    //   - if @arr_of_postgame_card_sets.blank?
    //     h3.h3 No Games Have Been Played

    //   - else
    //     h3.h3.text-center All Games I've played
    //     h6.h6.text-center.glow = "( Colored 'Created By' cards were made by you. )"
    //     = render partial: 'shared/card_slideshow', locals: { arr_of_postgame_card_sets: @arr_of_postgame_card_sets}
{/*}*/}




// shared/card_slideshow.html.slim
// / locals : { arr_of_postgame_card_sets: [ @game1.cards_from_finished_game (, ...)]  }
//   / arr_of_postgame_card_sets :  [   [  [   [       [     ,      ] ], [  ] ] ]   ]
//   /                              g  gu  c   g_u_n   card     c

//   / The card.uploader_id compared to @current_user.id will reveal if current_user drew that card
//   / have text glow if
// .carousel-wrapper
//   - arr_of_postgame_card_sets.each_with_index do |game_card_set, game_card_set_index|
//     hr
//     h3.h3.game-index-counter = "Game #{game_card_set_index + 1}"
//     - game_card_set.each_with_index do |games_user, games_user_index|
//       - unless games_user_index == 0
//         hr.dotted-line

//       - carousel_id = "carousel-#{games_user_index}"
//       .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
//         /! Indicators
//         ol.carousel-indicators
//           - games_user.each_with_index do |card_container, card_container_index|
//             li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
//         /! Wrapper for slides
//         .carousel-inner
//           - games_user.each_with_index do |card_container, card_container_index|
//             .carousel-item.text-center class=(card_container_index == 0 ? 'active' : '')
//               - if(card_container[1].drawing?)

//                 img.d-block.text-center src=get_drawing_url(card_container[1]) alt='Drawing to Describe' style='max-width: 325px; max-height: 375px; margin: auto;'
//                 / = image_tag get_drawing_url(card_container[1]), alt: "Drawing to describe", class: 'd-block'
//               - elsif(card_container[1].description?)
//                 h4.h4.description-text.text-center = card_container[1].description_text

//               .carousel-caption.d-block
//                 - did_i_make_card = card_container[1].uploader_id == @current_user.id
//                 p.h4 class=(did_i_make_card ? 'glow': '') Created By:
//                 p.h5 class=(did_i_make_card ? 'glow': '') = card_container[0]



//         /! Controls
//         a.carousel-control-prev data-slide='prev' href="##{carousel_id}" role='button'
//           span.carousel-control-prev-icon aria-hidden="true"
//           span.sr-only Previous

//         a.carousel-control-next data-slide='next' href="##{carousel_id}" role='button'
//           span.carousel-control-next-icon aria-hidden="true"
//           span.sr-only Previous

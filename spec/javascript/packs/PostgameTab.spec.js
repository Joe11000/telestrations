import React from 'react';
import {shallow} from 'enzyme';
import PostGameTab from 'packs/postgame/TabBody/PostGameTab';
import {render, fireEvent} from 'react-testing-library';
import {CardTitle } from 'reactstrap';
import { mock_games_show_request } from '../mock_games_show_request';

import enzymeSerializer from 'enzyme-to-json/serializer';
expect.addSnapshotSerializer(enzymeSerializer)

describe('PostGameTab Component', () => {
  it('renders correctly', () => {
    debugger
    mock_games_show_request
    // const props = { , 
    //   current_user_info: mock_games_show_request.current_user_info }
// 
      // const props = {  mock_games_show_request.arr_of_postgame_card_set, 
      //                 current_user_info: mock_games_show_request.current_user_info, 
      //                  }

    const post_game_tab_component = shallow(<PostGameTab {...props} />);


    // {...this.statePostGameTab}
    // retrieveCardsForPostgame={this.retrieveCardsForPostgame}
    // selectTab={this.selectTab}





      let game_1 = {'id': 11, 'created_at_strftime': 'Mon Nov 1, 2018'}
      let game_2 = {'id': 22, 'created_at_strftime': 'Tues Nov 2, 2018'}
      let game_3 = {'id': 33, 'created_at_strftime': 'Wed Nov 3, 2018'}

      const mockRetrieveCardsForPostgame = jest.fn();

      let props = {
                     'all_postgames_of__current_user': [
                                                         {
                                                           'id': game_1.id,
                                                           'created_at_strftime': game_1.created_at_strftime
                                                         },
                                                         {
                                                           'id': game_2.id,
                                                           'created_at_strftime': game_2.created_at_strftime
                                                         },
                                                         {
                                                           'id': game_3.id,
                                                           'created_at_strftime': game_3.created_at_strftime
                                                         }
                                                       ],
                     'current_postgame_id': game_3.id,
                     'retrieveCardsForPostgame': mockRetrieveCardsForPostgame,
                     'selectTab': jest.fn(),
                     'retrieveCardsForPostgame': jest.fn(),
                   }

      const postgame_tab = shallow(<PostGameTab {...props} />)
      
      
      expect(postgame_tab.find('CardTitle').text()).toEqual('Post Game Results');
      expect(postgame_tab.find('GameSelector').length).toEqual(1);
      expect(postgame_tab.find('SlideshowList').length).toEqual(1);
  })


  // describe('while on the page', ()=>{
  //   describe('selects a different game in the dropdown selector', ()=>{
  //     fit("", ()=>{
  //       const carousel_item = shallow(CarouselItem)
  //     });
  //   });

  //   describe('selects the same game in the dropdown selector', ()=>{
  //     it("doesn't get other ", ()=>{
  //       expect(1).toEqual(1);

  //     });
  //   });
  // });
});

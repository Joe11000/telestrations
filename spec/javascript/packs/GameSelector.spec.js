import React from 'react';
import {shallow} from 'enzyme';
import GameSelector from 'packs/postgame/GameSelector';
import { mock_games_show_request } from '../mock_games_show_request';
import enzymeSerializer from 'enzyme-to-json/serializer';
expect.addSnapshotSerializer(enzymeSerializer);

describe('GameSelector Component', ()=>{
  describe('sets correct values', ()=>{
    it('onload, default selects last game played', ()=>{
      const mockRetrieveCardsForPostgame = jest.fn();
      
      const game_selector_props = {
        all_postgames_of__current_user: mock_games_show_request.OutOfGameCardUploadTab.out_of_game_cards,
        current_postgame_id: mock_games_show_request.PostGameTab.current_postgame_id,
        retrieveCardsForPostgame: mockRetrieveCardsForPostgame
      }
      const GameSelector = shallow(<GameSelector {...game_selector_props } />);
      // const GameSelector = mount(<GameSelector {...game_selector_props } />);
      debugger;

      expect(GameSelector.find("select").props().value).toEqual(7);
    });

    xit('selector onChange calls props.retrieveCardsForPostgame(game_id)', ()=>{
    //   let game_1 = {'id': 11, 'created_at_strftime': 'Mon Nov 1, 2018'}
    //   let game_2 = {'id': 22, 'created_at_strftime': 'Tues Nov 2, 2018'}
    //   let game_3 = {'id': 33, 'created_at_strftime': 'Wed Nov 3, 2018'}

    //   const mockRetrieveCardsForPostgame = jest.fn()

    //   let props = {
    //                   'all_postgames_of__current_user': [
    //                                                       {
    //                                                         'id': game_1.id,
    //                                                         'created_at_strftime': game_1.created_at_strftime
    //                                                       },
    //                                                       {
    //                                                         'id': game_2.id,
    //                                                         'created_at_strftime': game_2.created_at_strftime
    //                                                       },
    //                                                       {
    //                                                         'id': game_3.id,
    //                                                         'created_at_strftime': game_3.created_at_strftime
    //                                                       }
    //                                                     ],

    //                   'current_postgame_id': game_3.id,
    //                   'retrieveCardsForPostgame': mockRetrieveCardsForPostgame
    //                 }

    //   const GameSelector = shallow(<GameSelector {...props} />)

      
      mock_games_show_request.OutOfGameCardUploadTab.out_of_game_cards.last

      const change_to_value = game_1.id;
      let params = {'target': {'value': change_to_value }, "preventDefault": ()=>{} }

      GameSelector.find('select').simulate('change',  params )

      expect(mockRetrieveCardsForPostgame.mock.calls.length).toBe(1)
      expect(mockRetrieveCardsForPostgame).toBeCalledWith(change_to_value)
    });
  });
});

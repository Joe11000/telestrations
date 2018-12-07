import React from 'react'
import {shallow} from 'enzyme'
import GameSelector from 'packs/postgame/GameSelector'
import {render, fireEvent} from 'react-testing-library'

import enzymeSerializer from 'enzyme-to-json/serializer'
expect.addSnapshotSerializer(enzymeSerializer)

describe('GameSelector Component', ()=>{
  it('has propTypes', ()=>{

    // props = {
    //           all_postgames_of__current_user: PropTypes.shape({
    //             id: PropTypes.number.isRequired,
    //             created_at_strftime: PropTypes.string.isRequired
    //           }),
    //           retrieveCardsForPostgame: PropTypes.func.isRequired

    //         }
  })

  describe('sets correct values', ()=>{
    it('onload', ()=>{
      let game_1 = {'id': 11, 'created_at_strftime': 'Mon Nov 1, 2018'}
      let game_2 = {'id': 22, 'created_at_strftime': 'Tues Nov 2, 2018'}
      let game_3 = {'id': 33, 'created_at_strftime': 'Wed Nov 3, 2018'}

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

                      'retrieveCardsForPostgame': jest.fn()
                    }

      const game_selector = shallow(<GameSelector {...props} />)

      expect( game_selector).toMatchSnapshot();
    });

    test.only('selector onChange calls props.retrieveCardsForPostgame(game_id)', ()=>{
      let game_1 = {'id': 11, 'created_at_strftime': 'Mon Nov 1, 2018'}
      let game_2 = {'id': 22, 'created_at_strftime': 'Tues Nov 2, 2018'}
      let game_3 = {'id': 33, 'created_at_strftime': 'Wed Nov 3, 2018'}

      const mockRetrieveCardsForPostgame = jest.fn()

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

                      'retrieveCardsForPostgame': mockRetrieveCardsForPostgame
                    }

      const game_selector = shallow(<GameSelector {...props} />)

      const change_to_value = `${game_1.id}`
      let params = {'target': {'value': change_to_value }, "preventDefault": ()=>{} }
      game_selector.find('select').simulate('change',  params )

      expect(mockRetrieveCardsForPostgame.mock.calls.length).toBe(1)
      expect(mockRetrieveCardsForPostgame).toBeCalledWith(game_1.id)
    });
  });
});

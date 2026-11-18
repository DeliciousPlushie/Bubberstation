import { useState } from 'react';
import { UI_UPDATE } from 'tgui-core/constants';
import { sleep } from 'tgui-core/timer';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Input,
  Section,
  Stack,
  Tabs,
} from '../bubber_components';
import { AceEditor } from '../bubber_components/ACE/Editor';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';
import { radioDisplay } from './common/radioDisplay';
// NTSLTextArea component start
// This is literally just TextArea but without ENTER updating anything, for NTSL

type NTSLTextAreaProps = {
  storedNtslCode: [string, (field: string) => void];
};

// NTSLTextArea component end

type Data = {
  admin_view: boolean;
  emagged: boolean;
  stored_code: string;
  user_name: string;
  network: string;
  compiler_output: string[];
  access_log: string[];
  server_data: Server_Data[];
};

type Server_Data = {
  run_code: boolean;
  server: string;
  server_name: string;
};

export const NTSLCoding = (props) => {
  const { act, data } = useBackend<Data>();
  const { emagged, user_name, admin_view } = data;
  // Make sure we don't start larger than 50%/80% of screen width/height.
  const winWidth = Math.min(
    user_name ? 900 : 250,
    window.screen.availWidth * 0.5,
  );
  const winHeight = Math.min(
    user_name ? 600 : 240,
    window.screen.availHeight * 0.8,
  );

  const storedNtslCode = useState('');
  const [tabIndex, setTabIndex] = useState(1);

  return (
    <Window title="电信流量控制台" width={winWidth} height={winHeight}>
      <Window.Content>
        <Stack fill>
          {user_name && (
            <Stack.Item width={winWidth - 240}>
              <ScriptEditor storedNtslCode={storedNtslCode} />
            </Stack.Item>
          )}
          <Stack.Item>
            {admin_view ? (
              <Button
                icon="power-off"
                color="red"
                onClick={() => act('admin_reset')}
              >
                管理员：重置代码并重新编译
              </Button>
            ) : (
              ''
            )}
            <Section width="240px">
              {user_name ? (
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="power-off"
                      color="purple"
                      disabled={emagged}
                      onClick={() => act('log_out')}
                    >
                      退出登录
                    </Button>
                  </Stack.Item>
                  <Stack.Item verticalAlign="middle">{user_name}</Stack.Item>
                </Stack>
              ) : (
                <Button
                  icon="power-off"
                  color="green"
                  onClick={() => act('log_in')}
                >
                  登录
                </Button>
              )}
            </Section>
            {user_name && (
              <Section width="240px" height="90%" fill>
                <Tabs>
                  <Tabs.Tab
                    selected={tabIndex === 1}
                    onClick={() => setTabIndex(1)}
                  >
                    编译
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 2}
                    onClick={() => setTabIndex(2)}
                  >
                    网络
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 3}
                    onClick={() => setTabIndex(3)}
                  >
                    日志
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 4}
                    onClick={() => setTabIndex(4)}
                  >
                    参考
                  </Tabs.Tab>
                </Tabs>
                {tabIndex === 1 && (
                  <CompilerOutput storedNtslCode={storedNtslCode} />
                )}
                {tabIndex === 2 && <ServerList />}
                {tabIndex === 3 && <LogViewer />}
                {tabIndex === 4 && <Guide />}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ScriptEditor = (props: NTSLTextAreaProps) => {
  const { act, data, config } = useBackend<Data>();
  const { stored_code, user_name } = data;
  const [_ntslCode, setNtslCode] = props.storedNtslCode;

  return (
    <Box width="100%" height="100%">
      <AceEditor
        value={stored_code}
        language="ntsl"
        width="100%"
        height="100%"
        onChange={setNtslCode}
        style={{
          mixBlendMode: 'overlay',
        }}
        onCtrlS={(value) => {
          if (value === '') return false;
          act('save_code', { saved_code: value });
          return true;
        }}
        onCtrlShiftB={(value) => {
          act('save_code', { saved_code: value });
          sleep(150).then(() => act('compile_code'));
          return true;
        }}
        readOnly={!user_name || config.status <= UI_UPDATE}
      />
    </Box>
  );
};

const CompilerOutput = (props: NTSLTextAreaProps) => {
  const { act, data } = useBackend<Data>();
  const { compiler_output } = data;
  const [ntslCode] = props.storedNtslCode;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="save"
          disabled={ntslCode === ''}
          tooltip={
            '编译前请先保存。在编辑器中按 Ctrl-S 即可保存。'
          }
          onClick={() => act('save_code', { saved_code: ntslCode })}
        >
          保存
        </Button>
      </Box>
      <Box>
        <Button
          mb={1}
          icon="running"
          onClick={() => act('compile_code')}
          tooltip={'在编辑器中按 Ctrl-Shift-B 即可保存并编译。'}
        >
          编译并运行
        </Button>
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {compiler_output
          ? compiler_output.map((error_message, index) => (
              <Box key={index}>{error_message}</Box>
            ))
          : '没有编译错误。'}
      </Section>
    </>
  );
};

const ServerList = (props) => {
  const { act, data } = useBackend<Data>();
  const { network, server_data } = data;
  return (
    <>
      <Box>
        <Button mb={1} icon="sync" onClick={() => act('refresh_servers')}>
          重新连接网络
        </Button>
      </Box>
      <Box>
        <Input
          mb={1}
          value={network}
          onBlur={(value) =>
            act('set_network', {
              new_network: value,
            })
          }
        />
      </Box>
      <Divider />
      <Section fill scrollable height="82%">
        {server_data.map((nt_server, index) => (
          <Box key={index}>
            <Button.Checkbox
              mb={0.5}
              checked={nt_server.run_code}
              onClick={() =>
                act('toggle_code_execution', {
                  selected_server: nt_server.server,
                })
              }
            >
              {nt_server.server_name}
            </Button.Checkbox>
          </Box>
        ))}
      </Section>
    </>
  );
};

const LogViewer = (props) => {
  const { act, data } = useBackend<Data>();
  const { access_log } = data;
  // This is terrible but nothing else will work
  return (
    <>
      <Box>
        <Button mb={1} icon="trash" onClick={() => act('clear_logs')}>
          清空日志
        </Button>
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {access_log
          ? access_log.map((access_message, index) => (
              <Box key={index}>{access_message}</Box>
            ))
          : '找不到访问日志，请联系管理员。'}
      </Section>
    </>
  );
};

// These frequencies wont show up the list of the frequencies in the guide,
// Because you cant use them.
const blacklistedChannels = [
  'Syndicate',
  'Red Team',
  'Blue Team',
  'Green Team',
  'Yellow Team',
];

const Guide = (props) => {
  return (
    <Section fill scrollable height="95.5%">
      纳米传讯认可的频率 <br />
      例如：channels.common <br />
      {RADIO_CHANNELS.filter(
        (channel) => !blacklistedChannels.includes(channel.name),
      ).map((channel, index) => (
        <div key={index} style={{ color: channel.color }}>
          {radioDisplay(channel.name)}：{channel.freq}
        </div>
      ))}
      <br />
      信号字段
      <br />
      source：发言者姓名。
      <br />
      content：发言内容。
      <br />
      job：发言者的职业。
      <br />
      freq：频道频率，见上方频率表。
      <br />
      pass：布尔值，决定是否放行消息。
      <br />
      say：陈述时使用的动词。
      <br />
      ask：提问时使用的动词。
      <br />
      yell：喊叫时使用的动词。
      <br />
      exclaim：惊呼时使用的动词。
      <br />
      filters：见下方无线电滤镜。
      <br />
      language：见下方支持的语言。
      <br />
      <br />
      纳米传讯无线电滤镜 <br />
      用法示例：filter_types.robot <br />字体 <br />
      robot：机械音（&quot;robot&quot;） <br />
      wacky：滑稽（&quot;sans&quot;） <br />文字效果 <br />
      <i>emphasis：强调（&quot;italics&quot;）</i> <br />
      <b>loud：大喊（&quot;yell&quot;）</b> <br />
      commanding：指挥口吻（&quot;command_headset&quot;） <br />
      <br /> {/* Btw, clown is also allowed. But we don't tell them that */}
      <br />
      纳米传讯支持的语言 <br />
      用法示例：languages.common <br />1 银河通用语（common） <br />2 黑猩猩语（monkey） <br />3
      编码音频语言（robot） <br />4 龙语（draconic） <br />5 海滩俚语（beachtounge） <br />6 林语（sylvan） <br />7
      电语（voltaic） <br />8 骨语（calcic） <br />9 蛾语（moffic） <br />
      10 灰烬语（ash） <br />
      11 火星洋语（yangyu） <br />
      12 银河异通用语（uncommon） <br />
      13 冥王星语（gutter） <br />
      14 猫语（nekomimetic） <br />
      15 史莱姆语（slime） <br />
      16 西克玛斯语（siikmaas） <br />
      17 太空人语（spacer） <br />
      18 泰维鲁阿科语（te velu akko） <br />
      19 斯拉夫共通语（interslavic） <br />
      20 犬语（canilunzt） <br />
      21 斯克雷尔语（skrell） <br />
      22 谢奇语（schechi） <br />
      23 玛尔语（marish） <br />
      <br />
      <br />
      脚本广播的信号不会再次触发脚本。
    </Section>
  );
};
